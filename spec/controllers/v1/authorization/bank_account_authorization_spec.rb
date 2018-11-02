# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'authorization for', type: :request do
  context 'bank_accounts' do
    let!(:record) { create(:bank_account) }
    include_examples 'forbid access for ews authenticated users',
                     BANK_ACCOUNTS_ENDPOINT,
                     resource: 'bank-accounts',
                     except: []
  end

  context 'bank_accounts' do
    let!(:permitted_user) { create(:user) }
    let!(:permitted_mandate) { create(:mandate) }
    let!(:random_mandate) { create(:mandate) }
    let!(:fund) { create(:fund) }
    let!(:forbidden_bank_account) { create(:bank_account, owner: random_mandate) }
    let!(:permitted_bank_account) { create(:bank_account, owner: permitted_mandate) }
    let!(:fund_bank_account) { create(:bank_account, owner: fund) }
    let!(:mandate_group) { create(:mandate_group, mandates: [permitted_mandate]) }
    let(:headers) { { 'Content-Type' => 'application/vnd.api+json' } }
    let(:auth_headers) { Devise::JWT::TestHelpers.auth_headers(headers, permitted_user) }

    def response_data
      JSON.parse(response.body)['data']
    end

    describe '#index' do
      let(:endpoint) { ->(auth_headers) { get BANK_ACCOUNTS_ENDPOINT, headers: auth_headers } }

      it 'excludes bank_accounts that no permissions exist for' do
        endpoint.call(auth_headers)

        expect(response.status).to eq(403)
      end

      describe 'with mandates_read role' do
        let!(:user_group) do
          create(:user_group, users: [permitted_user], mandate_groups: [mandate_group], roles: %i[mandates_read])
        end

        it 'includes bank_accounts for mandates which the user has permissions for' do
          endpoint.call(auth_headers)

          expect(BankAccount.count).to eq(3)
          expect(response_data.size).to eq(1)
        end
      end

      describe 'with mandates_read and funds_read role' do
        let!(:user_group) do
          create(
            :user_group, users: [permitted_user], mandate_groups: [mandate_group], roles: %i[mandates_read funds_read]
          )
        end

        it 'includes bank_accounts for mandates which the user has permissions for' do
          endpoint.call(auth_headers)

          expect(BankAccount.count).to eq(3)
          expect(response_data.size).to eq(2)
        end
      end

      describe '(xlsx request)' do
        let!(:user_group) do
          create(
            :user_group, users: [permitted_user], mandate_groups: [mandate_group],
                         roles: %i[mandates_export funds_export]
          )
        end
        let(:endpoint) { ->(h) { get BANK_ACCOUNTS_ENDPOINT, headers: xlsx_headers(h) } }

        permit :mandates_export, :funds_export
      end
    end

    describe '#show' do
      let(:endpoint) do
        ->(auth_headers) { get "#{BANK_ACCOUNTS_ENDPOINT}/#{bank_account.id}", headers: auth_headers }
      end
      let!(:user_group) do
        create(
          :user_group, users: [permitted_user], mandate_groups: [mandate_group], roles: %i[mandates_read funds_read]
        )
      end

      describe 'permitted bank_account' do
        let(:bank_account) { permitted_bank_account }

        permit :mandates_read
      end

      describe 'forbidden bank_account' do
        let(:bank_account) { forbidden_bank_account }

        permit # no role permits to see the forbidden bank account
      end

      describe 'fund bank_account' do
        let(:bank_account) { fund_bank_account }

        permit :funds_read
      end

      describe '(xlsx request)' do
        let(:bank_account) { permitted_bank_account }
        let!(:user_group) do
          create(:user_group, users: [permitted_user], mandate_groups: [mandate_group], roles: %i[mandates_export])
        end
        let(:endpoint) do
          ->(h) { get "#{BANK_ACCOUNTS_ENDPOINT}/#{bank_account.id}", headers: xlsx_headers(h) }
        end

        permit :mandates_export, :funds_export
      end
    end

    describe '#create' do
      let!(:user_group) do
        create(
          :user_group,
          users: [permitted_user],
          mandate_groups: [mandate_group],
          roles: %i[contacts_write mandates_write funds_write]
        )
      end
      let(:endpoint) do
        ->(auth_headers) { post BANK_ACCOUNTS_ENDPOINT, params: payload.to_json, headers: auth_headers }
      end
      let(:bank) { create(:contact_organization) }
      let(:mandate_owner) do
        {
          data: {
            id: mandate.id,
            type: 'mandates'
          }
        }
      end
      let(:fund_owner) do
        {
          data: {
            id: fund.id,
            type: 'funds'
          }
        }
      end
      let(:payload) do
        {
          data: {
            type: 'bank-accounts',
            attributes: {
              'account-type': 'currency_account',
              bic: 'BELADEBE',
              currency: 'EUR',
              iban: 'DE09100500006010000000',
              'owner-name': 'foo'
            },
            relationships: {
              bank: {
                data: {
                  id: bank.id,
                  type: 'contacts'
                }
              },
              owner: owner
            }
          }
        }
      end

      describe 'permitted mandate' do
        let(:owner) { mandate_owner }
        let(:mandate) { permitted_mandate }

        permit :mandates_write
      end

      describe 'mandate without permission' do
        let(:owner) { mandate_owner }
        let(:mandate) { random_mandate }

        permit # no role permits to create a bank account for a forbidden mandate
      end

      describe 'fund' do
        let(:owner) { fund_owner }

        permit :funds_write
      end

      describe '(xlsx request)' do
        let(:mandate) { permitted_mandate }
        let(:owner) { mandate_owner }
        let(:endpoint) do
          ->(h) { post BANK_ACCOUNTS_ENDPOINT, params: payload.to_json, headers: xlsx_headers(h) }
        end

        permit # none
      end
    end

    describe '#update', bullet: false do
      let!(:user_group) do
        create(
          :user_group,
          users: [permitted_user],
          mandate_groups: [mandate_group],
          roles: %i[contacts_write mandates_write funds_write]
        )
      end
      let(:endpoint) do
        lambda do |auth_headers|
          patch "#{BANK_ACCOUNTS_ENDPOINT}/#{bank_account.id}", params: payload.to_json, headers: auth_headers
        end
      end
      let(:mandate_owner) do
        {
          data: {
            id: mandate.id,
            type: 'mandates'
          }
        }
      end
      let(:fund_owner) do
        {
          data: {
            id: fund.id,
            type: 'funds'
          }
        }
      end
      let(:payload) do
        {
          data: {
            attributes: { iban: 'DE09100500006010000000' },
            id: bank_account.id,
            relationships: {
              owner: owner
            },
            type: 'bank-accounts'
          }
        }
      end

      describe 'permitted bank account' do
        let(:bank_account) { permitted_bank_account }
        let(:owner) { mandate_owner }

        describe 'permitted mandate' do
          let(:mandate) { permitted_mandate }

          permit :mandates_write
        end

        describe 'mandate without permission' do
          let(:mandate) { random_mandate }

          permit # no role permits to update a bank account for a forbidden mandate
        end
      end

      describe 'bank account of a mandate without permissions' do
        let(:bank_account) { forbidden_bank_account }
        let(:owner) { mandate_owner }

        describe 'permitted mandate' do
          let(:mandate) { permitted_mandate }

          permit # no role permits updating a bank account that was assigned to a forbidden mandate
        end

        describe 'mandate without permission' do
          let(:mandate) { random_mandate }

          permit # no role permits updating a bank account that was assigned to a forbidden mandate
        end
      end

      describe 'bank account of a fund' do
        let(:bank_account) { fund_bank_account }
        let(:owner) { fund_owner }

        permit :funds_write
      end

      describe '(xlsx request)' do
        let(:bank_account) { permitted_bank_account }
        let(:mandate) { permitted_mandate }
        let(:owner) { mandate_owner }
        let(:endpoint) do
          lambda do |h|
            patch "#{BANK_ACCOUNTS_ENDPOINT}/#{bank_account.id}", params: payload.to_json, headers: xlsx_headers(h)
          end
        end

        permit # none
      end
    end

    describe '#destroy' do
      let(:endpoint) do
        ->(auth_headers) { delete "#{BANK_ACCOUNTS_ENDPOINT}/#{bank_account.id}", headers: auth_headers }
      end
      let!(:user_group) do
        create(
          :user_group, users: [permitted_user], mandate_groups: [mandate_group],
                       roles: %i[mandates_destroy funds_destroy]
        )
      end

      describe 'permitted bank account' do
        let(:bank_account) { permitted_bank_account }

        permit :mandates_destroy
      end

      describe 'bank account of a mandate without permissions' do
        let(:bank_account) { forbidden_bank_account }

        permit # no role permits deleting a bank account that was assigned to a forbidden mandate
      end

      describe 'bank account of a fund' do
        let(:bank_account) { fund_bank_account }

        permit :funds_destroy
      end

      describe '(xlsx request)' do
        let(:bank_account) { permitted_bank_account }
        let(:endpoint) do
          ->(h) { delete "#{BANK_ACCOUNTS_ENDPOINT}/#{bank_account.id}", headers: xlsx_headers(h) }
        end

        permit # none
      end
    end
  end
end
