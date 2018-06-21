# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'authorization for', type: :request do
  let!(:record) { create(:tax_detail) }
  include_examples 'simple crud authorization',
                   TAX_DETAILS_ENDPOINT,
                   resource: 'tax_details',
                   permissions: {
                     destroy: :contacts_destroy,
                     read: :contacts_read,
                     write: :contacts_write
                   }
end
