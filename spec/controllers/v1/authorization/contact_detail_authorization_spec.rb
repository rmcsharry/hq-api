# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'authorization for', type: :request do
  let!(:record) { create(:phone) }
  include_examples 'simple crud authorization',
                   CONTACT_DETAILS_ENDPOINT,
                   resource: 'contact-details',
                   permissions: {
                     destroy: :contacts_destroy,
                     read: :contacts_read,
                     write: :contacts_write
                   }
end
