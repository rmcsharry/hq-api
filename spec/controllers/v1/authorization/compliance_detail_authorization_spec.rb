# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'authorization for', type: :request do
  let!(:record) { create(:compliance_detail) }
  include_examples 'simple crud authorization',
                   COMPLIANCE_DETAILS_ENDPOINT,
                   resource: 'compliance-details',
                   permissions: {
                     destroy: :contacts_destroy,
                     export: :contacts_export,
                     read: :contacts_read,
                     write: :contacts_write
                   }

  include_examples 'forbid access for ews authenticated users',
                   COMPLIANCE_DETAILS_ENDPOINT,
                   resource: 'compliance-details',
                   except: []
end
