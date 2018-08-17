# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'authorization for', type: :request do
  let!(:record) { create(:organization_member) }
  include_examples 'simple crud authorization',
                   ORGANIZATION_MEMBERS_ENDPOINT,
                   resource: 'organization-members',
                   permissions: {
                     destroy: :contacts_destroy,
                     read: :contacts_read,
                     write: :contacts_write
                   }

  include_examples 'forbid access for ews authenticated users',
                   ORGANIZATION_MEMBERS_ENDPOINT,
                   resource: 'organization-members',
                   except: []
end
