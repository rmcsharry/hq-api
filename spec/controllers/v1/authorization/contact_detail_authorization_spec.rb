# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'authorization for', type: :request do
  let!(:record) { create(:phone) }
  include_examples(
    'simple crud authorization',
    CONTACT_DETAILS_ENDPOINT,
    resource: 'contact-details',
    permissions: {
      destroy: :contacts_destroy,
      export: :contacts_export,
      read: :contacts_read,
      write: :contacts_write
    },
    create_payload: {
      data: {
        type: 'contact-details',
        attributes: {
          'contact-detail-type': 'ContactDetail::Phone'
        }
      }
    }
  )

  include_examples 'forbid access for ews authenticated users',
                   CONTACT_DETAILS_ENDPOINT,
                   resource: 'contact-details',
                   except: []
end
