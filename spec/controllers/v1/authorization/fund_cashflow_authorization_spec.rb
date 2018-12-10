# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'authorization for', type: :request do
  let!(:record) { create(:fund_cashflow) }
  include_examples(
    'simple crud authorization',
    FUND_CASHFLOWS_ENDPOINT,
    resource: 'fund_cashflows',
    permissions: {
      destroy: :funds_destroy,
      export: :funds_export,
      read: :funds_read,
      write: :funds_write
    }
  )

  include_examples 'forbid access for ews authenticated users', FUNDS_ENDPOINT, resource: 'funds'
end
