# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'authorization for', type: :request do
  let!(:record) { create(:foreign_tax_number) }
  include_examples 'simple crud authorization',
                   FOREIGN_TAX_NUMBERS_ENDPOINT,
                   resource: 'foreign_tax_numbers',
                   permissions: {
                     destroy: :contacts_destroy,
                     export: :contacts_export,
                     read: :contacts_read,
                     write: :contacts_write
                   }

  include_examples 'forbid access for ews authenticated users',
                   FOREIGN_TAX_NUMBERS_ENDPOINT,
                   resource: 'foreign_tax_numbers',
                   except: []
end
