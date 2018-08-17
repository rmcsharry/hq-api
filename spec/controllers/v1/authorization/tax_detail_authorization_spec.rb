# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'authorization for', type: :request do
  let!(:record) { create(:tax_detail) }
  include_examples 'simple crud authorization',
                   TAX_DETAILS_ENDPOINT,
                   resource: 'tax-details',
                   permissions: {
                     destroy: :contacts_destroy,
                     read: :contacts_read,
                     write: :contacts_write
                   }

  include_examples 'forbid access for ews authenticated users',
                   TAX_DETAILS_ENDPOINT,
                   resource: 'tax-details',
                   except: []
end
