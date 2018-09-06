# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'authorization for', type: :request do
  let!(:record) { create(:document) }
  include_examples 'simple crud authorization',
                   DOCUMENTS_ENDPOINT,
                   resource: 'documents',
                   permissions: {
                     destroy: :contacts_destroy,
                     export: :contacts_export,
                     read: :contacts_read,
                     write: :contacts_write
                   }

  include_examples 'forbid access for ews authenticated users',
                   DOCUMENTS_ENDPOINT,
                   resource: 'documents',
                   except: []
end
