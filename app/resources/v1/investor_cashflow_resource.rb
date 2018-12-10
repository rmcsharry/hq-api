# frozen_string_literal: true

module V1
  # Defines the InvestorCashflow resource for the API
  class InvestorCashflowResource < BaseResource
    attributes(
      :capital_call_compensatory_interest_amount,
      :capital_call_gross_amount,
      :capital_call_management_fees_amount,
      :capital_call_total_amount,
      :distribution_compensatory_interest_amount,
      :distribution_dividends_amount,
      :distribution_interest_amount,
      :distribution_misc_profits_amount,
      :distribution_participation_profits_amount,
      :distribution_recallable_amount,
      :distribution_reduction_amount,
      :distribution_structure_costs_amount,
      :distribution_total_amount,
      :distribution_withholding_tax_amount,
      :net_cashflow_amount,
      :state
    )

    has_one :investor
    has_one :fund_cashflow

    filter :fund_cashflow_id

    class << self
      def updatable_fields(context)
        super(context) - %i[net_cashflow_amount capital_call_total_amount distribution_total_amount state]
      end
    end
  end
end
