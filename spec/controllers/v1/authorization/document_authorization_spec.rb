# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'authorization for', type: :request do
  let(:headers) { { 'Content-Type' => 'application/vnd.api+json' } }
  let(:auth_headers) { Devise::JWT::TestHelpers.auth_headers(headers, permitted_user) }

  def response_data
    JSON.parse(response.body)['data']
  end

  context 'documents' do
    let!(:fund_document) { create(:document, owner: fund) }
    let!(:mandate_document) { create(:document, owner: permitted_mandate) }
    let!(:contact_document) { create(:document, owner: contact_person) }
    let!(:activity_mandate_document) { create(:document, owner: mandate_activity) }
    let!(:activity_contact_document) { create(:document, owner: contact_activity) }
    let!(:forbidden_document) { create(:document, owner: forbidden_mandate) }
    let!(:forbidden_activity_document) { create(:document, owner: forbidden_mandate_activity) }

    let!(:fund) { create(:fund) }
    let!(:permitted_mandate) { create(:mandate, comment: 'permitted') }
    let!(:forbidden_mandate) { create(:mandate, comment: 'forbidden') }
    let!(:contact_person) { create(:contact_person) }
    let!(:forbidden_mandate_activity) { create(:activity_note, mandates: [forbidden_mandate]) }
    let!(:mandate_activity) { create(:activity_note, mandates: [permitted_mandate]) }
    let!(:contact_activity) { create(:activity_note, contacts: [contact_person]) }

    let!(:permitted_group) { create(:mandate_group, mandates: [permitted_mandate]) }
    let!(:forbidden_group) { create(:mandate_group, mandates: [forbidden_mandate]) }
    let!(:permitted_user) { create(:user) }
    let!(:random_user) { create(:user) }
    let!(:user_group_with_missing_role) do
      create(:user_group, users: [permitted_user], mandate_groups: [forbidden_group], roles: [])
    end
    let!(:user_group_random_user) do
      create(:user_group, users: [random_user], mandate_groups: [forbidden_group], roles: [:mandates_read])
    end

    describe '#index' do
      let(:endpoint) { ->(auth_headers) { get DOCUMENTS_ENDPOINT, headers: auth_headers } }

      def response_ids
        response_data.map do |datum|
          datum['id']
        end
      end

      it 'operates on a total of seven documents' do
        expect(Document.count).to eq(7)
      end

      context 'without any relevant roles' do
        it 'forbids access if no permission exists for any owner type' do
          endpoint.call(auth_headers)
          expect(response.status).to eq(403)
        end

        describe '(xlsx request)', bullet: false do
          let(:endpoint) { ->(h) { get DOCUMENTS_ENDPOINT, headers: xlsx_headers(h) } }

          it 'is not permitted' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(403)
          end
        end
      end

      context 'with contacts_read role' do
        before do
          create(:user_group, users: [permitted_user], roles: [:contacts_read])
        end

        it 'includes documents of activities (with assigned contacts) and contacts' do
          endpoint.call(auth_headers)
          expect(response_ids).to contain_exactly(contact_document.id, activity_contact_document.id)
        end

        describe '(xlsx request)', bullet: false do
          let(:endpoint) { ->(h) { get DOCUMENTS_ENDPOINT, headers: xlsx_headers(h) } }

          before do
            create(:user_group, users: [permitted_user], roles: [:contacts_export])
          end

          it 'permits contacts_export role' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(200)
          end
        end
      end

      context 'with mandates_read role' do
        before do
          create(:user_group, users: [permitted_user], mandate_groups: [permitted_group], roles: [:mandates_read])
        end

        it 'includes documents of activities (with assigned mandates) and mandates' do
          endpoint.call(auth_headers)
          expect(response_ids).to contain_exactly(mandate_document.id, activity_mandate_document.id)
        end

        describe '(xlsx request)', bullet: false do
          let(:endpoint) { ->(h) { get DOCUMENTS_ENDPOINT, headers: xlsx_headers(h) } }

          before do
            create(:user_group, users: [permitted_user], mandate_groups: [permitted_group], roles: [:mandates_export])
          end

          it 'permits contacts_export role' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(200)
          end
        end
      end

      context 'with funds_read role' do
        before do
          create(:user_group, users: [permitted_user], roles: [:funds_read])
        end

        it 'includes documents of funds' do
          endpoint.call(auth_headers)
          expect(response_ids).to contain_exactly(fund_document.id)
        end

        describe '(xlsx request)', bullet: false do
          let(:endpoint) { ->(h) { get DOCUMENTS_ENDPOINT, headers: xlsx_headers(h) } }

          before do
            create(:user_group, users: [permitted_user], roles: [:funds_export])
          end

          it 'permits contacts_export role' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(200)
          end
        end
      end

      context 'with contacts_read, funds_read and mandates_read roles' do
        before do
          create(
            :user_group,
            users: [permitted_user],
            mandate_groups: [permitted_group],
            roles: %i[contacts_read funds_read mandates_read]
          )
        end

        it 'includes documents of contacts, funds, mandates and their activities' do
          endpoint.call(auth_headers)
          expect(response_ids).to(
            contain_exactly(
              activity_contact_document.id,
              activity_mandate_document.id,
              contact_document.id,
              fund_document.id,
              mandate_document.id
            )
          )
        end
      end
    end

    describe '#show', bullet: false do
      let(:endpoint) do
        ->(auth_headers) { get "#{DOCUMENTS_ENDPOINT}/#{document.id}", headers: auth_headers }
      end

      context 'without any relevant roles' do
        let(:document) { contact_document }

        it 'forbids access if no permission exists for the owner type' do
          endpoint.call(auth_headers)
          expect(response.status).to eq(403)
        end
      end

      context 'with contacts_read role and owner of type' do
        before do
          create(:user_group, users: [permitted_user], roles: [:contacts_read])
        end

        context 'contact' do
          let(:document) { contact_document }

          it 'permits access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(200)
          end
        end

        context 'activity that is assigned to a contact' do
          let(:document) { activity_contact_document }

          it 'permits access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(200)
          end
        end

        context 'activity that is assigned to a mandate' do
          let(:document) { activity_mandate_document }

          it 'forbids access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(403)
          end
        end

        context 'mandate' do
          let(:document) { mandate_document }

          it 'forbids access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(403)
          end
        end

        context 'fund' do
          let(:document) { fund_document }

          it 'forbids access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(403)
          end
        end
      end

      context 'with mandates_read role and owner of type' do
        before do
          create(:user_group, users: [permitted_user], mandate_groups: [permitted_group], roles: [:mandates_read])
        end

        context 'contact' do
          let(:document) { contact_document }

          it 'forbids access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(403)
          end
        end

        context 'activity that is assigned to a contact' do
          let(:document) { activity_contact_document }

          it 'forbids access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(403)
          end
        end

        context 'activity that is assigned to a mandate' do
          let(:document) { activity_mandate_document }

          it 'permits access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(200)
          end
        end

        context 'mandate' do
          let(:document) { mandate_document }

          it 'permits access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(200)
          end
        end

        context 'forbidden mandate' do
          let(:document) { forbidden_document }

          it 'forbids access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(403)
          end
        end

        context 'activity for forbidden mandate' do
          let(:document) { forbidden_activity_document }

          it 'forbids access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(403)
          end
        end

        context 'fund' do
          let(:document) { fund_document }

          it 'forbids access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(403)
          end
        end
      end

      context 'with funds_read role' do
        before do
          create(:user_group, users: [permitted_user], roles: [:funds_read])
        end

        context 'contact' do
          let(:document) { contact_document }

          it 'forbids access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(403)
          end
        end

        context 'activity that is assigned to a contact' do
          let(:document) { activity_contact_document }

          it 'forbids access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(403)
          end
        end

        context 'activity that is assigned to a mandate' do
          let(:document) { activity_mandate_document }

          it 'forbids access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(403)
          end
        end

        context 'mandate' do
          let(:document) { mandate_document }

          it 'forbids access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(403)
          end
        end

        context 'fund' do
          let(:document) { fund_document }

          it 'permits access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(200)
          end
        end
      end
    end

    describe '#create' do
      let(:headers) { { 'Content-Type' => 'multipart/related' } }
      let(:endpoint) do
        ->(auth_headers) { post DOCUMENTS_ENDPOINT, params: payload, headers: auth_headers }
      end
      let(:file) do
        Rack::Test::UploadedFile.new(
          Rails.root.join('spec', 'fixtures', 'pdfs', 'hqtrust_sample.pdf'),
          'application/pdf'
        )
      end
      let(:payload) do
        owner_resource_class = JSONAPI::Resource.resource_klass_for('V1::' + owner.class.name.split('::').first)
        owner_type = owner_resource_class._type.to_s.dasherize
        {
          data: {
            type: 'documents',
            attributes: {
              'document-type': 'Document',
              'valid-from': '2004-05-29',
              'valid-to': '2015-12-27',
              category: 'contract_hq',
              name: 'name',
              file: 'cid:file:0'
            },
            relationships: {
              owner: {
                data: {
                  id: owner.id,
                  type: owner_type
                }
              }
            }
          }.to_json,
          'file:0': file
        }
      end

      context 'with contacts_write role and owner of type' do
        before do
          create(:user_group, users: [permitted_user], roles: [:contacts_write])
        end

        context 'contact' do
          let(:owner) { contact_person }

          it 'permits access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(201)
          end
        end

        context 'activity that is assigned to a contact' do
          let(:owner) { contact_activity }

          it 'permits access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(201)
          end
        end

        context 'activity that is assigned to a mandate' do
          let(:owner) { mandate_activity }

          it 'forbids access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(403)
          end
        end

        context 'mandate' do
          let(:owner) { permitted_mandate }

          it 'forbids access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(403)
          end
        end

        context 'fund' do
          let(:owner) { fund }

          it 'forbids access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(403)
          end
        end
      end

      context 'with mandates_write role and owner of type' do
        before do
          create(:user_group, users: [permitted_user], mandate_groups: [permitted_group], roles: [:mandates_write])
        end

        context 'contact' do
          let(:owner) { contact_person }

          it 'forbids access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(403)
          end
        end

        context 'activity that is assigned to a contact' do
          let(:owner) { contact_activity }

          it 'forbids access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(403)
          end
        end

        context 'activity that is assigned to a mandate' do
          let(:owner) { mandate_activity }

          it 'permits access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(201)
          end
        end

        context 'mandate' do
          let(:owner) { permitted_mandate }

          it 'permits access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(201)
          end
        end

        context 'forbidden mandate' do
          let(:owner) { forbidden_mandate }

          it 'forbids access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(403)
          end
        end

        context 'activity for forbidden mandate' do
          let(:owner) { forbidden_mandate_activity }

          it 'forbids access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(403)
          end
        end

        context 'fund' do
          let(:owner) { fund }

          it 'forbids access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(403)
          end
        end
      end

      context 'with funds_write role' do
        before do
          create(:user_group, users: [permitted_user], roles: [:funds_write])
        end

        context 'contact' do
          let(:owner) { contact_person }

          it 'forbids access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(403)
          end
        end

        context 'activity that is assigned to a contact' do
          let(:owner) { contact_activity }

          it 'forbids access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(403)
          end
        end

        context 'activity that is assigned to a mandate' do
          let(:owner) { mandate_activity }

          it 'forbids access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(403)
          end
        end

        context 'mandate' do
          let(:owner) { permitted_mandate }

          it 'forbids access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(403)
          end
        end

        context 'fund' do
          let(:owner) { fund }

          it 'permits access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(201)
          end
        end
      end
    end

    describe '#update', bullet: false do
      let(:endpoint) do
        lambda do |auth_headers|
          patch "#{DOCUMENTS_ENDPOINT}/#{document.id}", params: payload.to_json, headers: auth_headers
        end
      end
      let(:document) { create :document, owner: owner }
      let(:payload) do
        {
          data: {
            type: 'documents',
            attributes: {
              name: 'new document name'
            },
            id: document.id
          }
        }
      end

      context 'with contacts_write role and owner of type' do
        before do
          create(:user_group, users: [permitted_user], roles: [:contacts_write])
        end

        context 'contact' do
          let(:owner) { contact_person }

          it 'permits access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(200)
          end
        end

        context 'activity that is assigned to a contact' do
          let(:owner) { contact_activity }

          it 'permits access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(200)
          end
        end

        context 'activity that is assigned to a mandate' do
          let(:owner) { mandate_activity }

          it 'forbids access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(403)
          end
        end

        context 'mandate' do
          let(:owner) { permitted_mandate }

          it 'forbids access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(403)
          end
        end

        context 'fund' do
          let(:owner) { fund }

          it 'forbids access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(403)
          end
        end
      end

      context 'with mandates_write role and owner of type' do
        before do
          create(:user_group, users: [permitted_user], mandate_groups: [permitted_group], roles: [:mandates_write])
        end

        context 'contact' do
          let(:owner) { contact_person }

          it 'forbids access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(403)
          end
        end

        context 'activity that is assigned to a contact' do
          let(:owner) { contact_activity }

          it 'forbids access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(403)
          end
        end

        context 'activity that is assigned to a mandate' do
          let(:owner) { mandate_activity }

          it 'permits access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(200)
          end
        end

        context 'mandate' do
          let(:owner) { permitted_mandate }

          it 'permits access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(200)
          end
        end

        context 'forbidden mandate' do
          let(:owner) { forbidden_mandate }

          it 'forbids access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(403)
          end
        end

        context 'activity for forbidden mandate' do
          let(:owner) { forbidden_mandate_activity }

          it 'forbids access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(403)
          end
        end

        context 'fund' do
          let(:owner) { fund }

          it 'forbids access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(403)
          end
        end
      end

      context 'with funds_write role' do
        before do
          create(:user_group, users: [permitted_user], roles: [:funds_write])
        end

        context 'contact' do
          let(:owner) { contact_person }

          it 'forbids access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(403)
          end
        end

        context 'activity that is assigned to a contact' do
          let(:owner) { contact_activity }

          it 'forbids access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(403)
          end
        end

        context 'activity that is assigned to a mandate' do
          let(:owner) { mandate_activity }

          it 'forbids access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(403)
          end
        end

        context 'mandate' do
          let(:owner) { permitted_mandate }

          it 'forbids access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(403)
          end
        end

        context 'fund' do
          let(:owner) { fund }

          it 'permits access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(200)
          end
        end
      end
    end

    describe '#destroy' do
      let(:endpoint) do
        ->(auth_headers) { delete "#{DOCUMENTS_ENDPOINT}/#{document.id}", headers: auth_headers }
      end

      describe '(xlsx request)' do
        before do
          create(:user_group, users: [permitted_user], roles: [:contacts_destroy])
        end

        let(:document) { contact_document }
        let(:endpoint) do
          ->(h) { delete "#{DOCUMENTS_ENDPOINT}/#{document.id}", headers: xlsx_headers(h) }
        end

        permit # none
      end

      context 'without any relevant roles' do
        let(:document) { contact_document }

        it 'forbids deletion if no permission exists for the owner type' do
          endpoint.call(auth_headers)
          expect(response.status).to eq(403)
        end
      end

      context 'with contacts_destroy role and owner of type' do
        before do
          create(:user_group, users: [permitted_user], roles: [:contacts_destroy])
        end

        context 'contact' do
          let(:document) { contact_document }

          it 'permits access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(204)
          end
        end

        context 'activity that is assigned to a contact' do
          let(:document) { activity_contact_document }

          it 'permits access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(204)
          end
        end

        context 'activity that is assigned to a mandate' do
          let(:document) { activity_mandate_document }

          it 'forbids access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(403)
          end
        end

        context 'mandate' do
          let(:document) { mandate_document }

          it 'forbids access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(403)
          end
        end

        context 'fund' do
          let(:document) { fund_document }

          it 'forbids access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(403)
          end
        end
      end

      context 'with mandates_destroy role and owner of type' do
        before do
          create(:user_group, users: [permitted_user], mandate_groups: [permitted_group], roles: [:mandates_destroy])
        end

        context 'contact' do
          let(:document) { contact_document }

          it 'forbids access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(403)
          end
        end

        context 'activity that is assigned to a contact' do
          let(:document) { activity_contact_document }

          it 'forbids access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(403)
          end
        end

        context 'activity that is assigned to a mandate' do
          let(:document) { activity_mandate_document }

          it 'permits access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(204)
          end
        end

        context 'mandate' do
          let(:document) { mandate_document }

          it 'permits access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(204)
          end
        end

        context 'forbidden mandate' do
          let(:document) { forbidden_document }

          it 'forbids access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(403)
          end
        end

        context 'activity for forbidden mandate' do
          let(:document) { forbidden_activity_document }

          it 'forbids access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(403)
          end
        end

        context 'fund' do
          let(:document) { fund_document }

          it 'forbids access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(403)
          end
        end
      end

      context 'with funds_destroy role' do
        before do
          create(:user_group, users: [permitted_user], roles: [:funds_destroy])
        end

        context 'contact' do
          let(:document) { contact_document }

          it 'forbids access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(403)
          end
        end

        context 'activity that is assigned to a contact' do
          let(:document) { activity_contact_document }

          it 'forbids access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(403)
          end
        end

        context 'activity that is assigned to a mandate' do
          let(:document) { activity_mandate_document }

          it 'forbids access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(403)
          end
        end

        context 'mandate' do
          let(:document) { mandate_document }

          it 'forbids access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(403)
          end
        end

        context 'fund' do
          let(:document) { fund_document }

          it 'permits access' do
            endpoint.call(auth_headers)
            expect(response.status).to eq(204)
          end
        end
      end
    end
  end
end
