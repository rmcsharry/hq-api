# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'authorization for', type: :request do
  let!(:record) { create(:mandate_member) }
  include_examples 'simple crud authorization',
                   MANDATE_MEMBERS_ENDPOINT,
                   resource: 'mandate_members',
                   permissions: {
                     destroy: :contacts_destroy,
                     read: :contacts_read,
                     write: :contacts_write
                   }
end
