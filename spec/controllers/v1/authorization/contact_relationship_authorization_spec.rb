# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'authorization for', type: :request do
  let!(:record) { create(:person_person_relationship) }
  include_examples 'simple crud authorization',
                   CONTACT_RELATIONSHIPS_ENDPOINT,
                   resource: 'contact_relationships',
                   permissions: {
                     destroy: :contacts_destroy,
                     export: :contacts_export,
                     read: :contacts_read,
                     write: :contacts_write
                   }

  include_examples 'forbid access for ews authenticated users',
                   CONTACT_RELATIONSHIPS_ENDPOINT,
                   resource: 'contact_relationships',
                   except: []
end
