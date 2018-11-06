# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'authorization for', type: :request do
  let!(:record) { create(:contact_person) }
  include_examples(
    'simple crud authorization',
    CONTACTS_ENDPOINT,
    resource: 'contacts',
    permissions: {
      destroy: :contacts_destroy,
      export: :contacts_export,
      read: :contacts_read,
      write: :contacts_write
    },
    create_payload: {
      data: {
        type: 'contacts',
        attributes: {
          'contact-type': 'Contact::Person'
        }
      }
    }
  )

  include_examples 'forbid access for ews authenticated users',
                   CONTACTS_ENDPOINT,
                   resource: 'contacts',
                   except: [:index]

  describe 'contacts' do
    describe 'versions' do
      let!(:contact) { create(:contact_person) }
      let(:endpoint) do
        ->(auth_headers) { get "#{CONTACTS_ENDPOINT}/#{contact.id}/versions", headers: auth_headers }
      end

      permit :contacts_read

      describe '(xlsx request)' do
        let(:endpoint) do
          ->(h) { get "#{CONTACTS_ENDPOINT}/#{contact.id}/versions", headers: xlsx_headers(h) }
        end

        permit :contacts_export
      end
    end
  end
end
