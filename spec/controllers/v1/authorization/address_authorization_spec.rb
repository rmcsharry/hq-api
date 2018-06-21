# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'authorization for', type: :request do
  let!(:record) { create(:address) }
  include_examples 'simple crud authorization',
                   ADDRESSES_ENDPOINT,
                   resource: 'addresses',
                   permissions: {
                     destroy: :contacts_destroy,
                     read: :contacts_read,
                     write: :contacts_write
                   }
end
