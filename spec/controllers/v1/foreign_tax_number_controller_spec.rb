# frozen_string_literal: true

require 'rails_helper'
require 'devise/jwt/test_helpers'

RSpec.describe FOREIGN_TAX_NUMBERS_ENDPOINT, type: :request do
  let!(:user) { create(:user, roles: %i[contacts_read contacts_write contacts_destroy]) }
  let(:headers) { { 'Content-Type' => 'application/vnd.api+json' } }
  let(:auth_headers) { Devise::JWT::TestHelpers.auth_headers(headers, user) }

  describe 'POST /v1/foreign-tax-numbers' do
    let!(:contact) { create(:contact_person, :with_contact_details) }
    subject { -> { post(FOREIGN_TAX_NUMBERS_ENDPOINT, params: payload.to_json, headers: auth_headers) } }

    context 'with valid payload' do
      let(:payload) do
        {
          data: {
            type: 'foreign-tax-numbers',
            attributes: {
              country: 'AT',
              'tax-number': '0123456789'
            },
            relationships: {
              'tax-detail': {
                data: { id: contact.tax_detail.id, type: 'tax-details' }
              }
            }
          }
        }
      end

      it 'creates a new foreign tax number' do
        is_expected.to change(ForeignTaxNumber, :count).by(1)
        expect(response).to have_http_status(201)
        foreign_tax_number = ForeignTaxNumber.find(JSON.parse(response.body)['data']['id'])
        expect(foreign_tax_number.country).to eq 'AT'
        expect(foreign_tax_number.tax_number).to eq '0123456789'
      end
    end
  end

  describe 'PATCH /v1/foreign-tax-numbers' do
    let!(:foreign_tax_number) { create(:foreign_tax_number) }
    subject do
      lambda do
        patch(
          "#{FOREIGN_TAX_NUMBERS_ENDPOINT}/#{foreign_tax_number.id}", params: payload.to_json, headers: auth_headers
        )
      end
    end

    context 'with valid payload' do
      let(:payload) do
        {
          data: {
            type: 'foreign-tax-numbers',
            id: foreign_tax_number.id,
            attributes: {
              country: 'FR',
              'tax-number': '9876543210'
            }
          }
        }
      end

      it 'updates the foreign tax number' do
        is_expected.to change(ForeignTaxNumber, :count).by(0)
        expect(response).to have_http_status(200)
        foreign_tax_number.reload
        expect(foreign_tax_number.country).to eq 'FR'
        expect(foreign_tax_number.tax_number).to eq '9876543210'
      end
    end
  end

  describe 'DELETE /v1/foreign-tax-numbers' do
    let!(:foreign_tax_number) { create(:foreign_tax_number) }
    subject do
      lambda do
        delete(
          "#{FOREIGN_TAX_NUMBERS_ENDPOINT}/#{foreign_tax_number.id}", params: {}, headers: auth_headers
        )
      end
    end

    context 'with valid payload' do
      it 'deletes the foreign tax number' do
        is_expected.to change(ForeignTaxNumber, :count).by(-1)
        expect(response).to have_http_status(204)
      end
    end
  end
end
