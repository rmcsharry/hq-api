# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'authorization for', type: :request do
  let!(:record) { create(:inter_person_relationship) }
  include_examples 'simple crud authorization',
                   INTER_PERSON_RELATIONSHIPS_ENDPOINT,
                   resource: 'inter_person_relationships',
                   permissions: {
                     destroy: :contacts_destroy,
                     read: :contacts_read,
                     write: :contacts_write
                   }
end
