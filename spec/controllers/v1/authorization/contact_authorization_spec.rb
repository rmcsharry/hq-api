# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'authorization for', type: :request do
  let!(:record) { create(:contact_person) }
  include_examples 'simple crud authorization',
                   CONTACTS_ENDPOINT,
                   resource: 'contacts',
                   permissions: {
                     destroy: :contacts_destroy,
                     read: :contacts_read,
                     write: :contacts_write
                   }

  include_examples 'forbid access for ews authenticated users',
                   CONTACTS_ENDPOINT,
                   resource: 'contacts',
                   except: [:index]
end
