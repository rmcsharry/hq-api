# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'authorization for', type: :request do
  let!(:record) { create(:user_group) }
  include_examples 'simple crud authorization',
                   USER_GROUPS_ENDPOINT,
                   resource: 'user-groups',
                   permissions: {
                     destroy: :admin,
                     export: :admin,
                     read: :admin,
                     write: :admin
                   }

  include_examples 'forbid access for ews authenticated users',
                   USER_GROUPS_ENDPOINT,
                   resource: 'user-groups',
                   except: []
end
