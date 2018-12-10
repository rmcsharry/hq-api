# frozen_string_literal: true

module V1
  # Defines the FundCashflow resource for the API
  class FundCashflowResource < BaseResource
    attributes(
      :fund_cashflow_type,
      :investor_count,
      :net_cashflow_amount,
      :number,
      :state,
      :valuta_date
    )

    has_one :fund
    has_many :investor_cashflows

    filter :fund_id

    sort :net_cashflow_amount, apply: lambda { |records, direction, _context|
      records.with_net_cashflow_amount.order("net_cashflow_amount #{direction}")
    }

    sort :fund_cashflow_type, apply: lambda { |records, direction, _context|
      records.with_net_cashflow_amount.order("net_cashflow_amount >= 0 #{direction}")
    }

    sort :state, apply: lambda { |records, direction, _context|
      records.with_open_state_count.order("open_state_count >= 0 #{direction}")
    }

    def investor_count
      @model.investor_cashflows.count
    end

    class << self
      def updatable_fields(context)
        super(context) - %i[investor_count fund_cashflow_type number net_cashflow_amount]
      end

      def sortable_fields(context)
        super(context) - %i[investor_count]
      end
    end
  end
end
