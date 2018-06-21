# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'authorization for', type: :request do
  let!(:record) { create(:user_group) }
  include_examples 'simple crud authorization',
                   USER_GROUPS_ENDPOINT,
                   resource: 'user_groups',
                   permissions: {
                     destroy: :admin,
                     read: :admin,
                     write: :admin
                   }
end
