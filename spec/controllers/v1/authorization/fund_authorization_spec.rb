# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'authorization for', type: :request do
  let!(:record) { create(:fund) }
  include_examples 'simple crud authorization',
                   FUNDS_ENDPOINT,
                   resource: 'funds',
                   permissions: {
                     destroy: :funds_destroy,
                     export: :funds_export,
                     read: :funds_read,
                     write: :funds_write
                   }

  include_examples 'forbid access for ews authenticated users', FUNDS_ENDPOINT, resource: 'funds'

  describe 'contacts' do
    describe 'versions' do
      let!(:fund) { create(:fund) }
      let(:endpoint) do
        ->(auth_headers) { get "#{FUNDS_ENDPOINT}/#{fund.id}/versions", headers: auth_headers }
      end

      permit :funds_read

      describe '(xlsx request)' do
        let(:endpoint) do
          ->(h) { get "#{FUNDS_ENDPOINT}/#{fund.id}/versions", headers: xlsx_headers(h) }
        end

        permit :funds_export
      end
    end
  end
end
