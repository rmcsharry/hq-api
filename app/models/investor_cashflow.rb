# frozen_string_literal: true

# == Schema Information
#
# Table name: investor_cashflows
#
#  id                                        :uuid             not null, primary key
#  aasm_state                                :string
#  distribution_reduction_amount             :decimal(20, 10)  default(0.0), not null
#  distribution_participation_profits_amount :decimal(20, 10)  default(0.0), not null
#  distribution_dividends_amount             :decimal(20, 10)  default(0.0), not null
#  distribution_interest_amount              :decimal(20, 10)  default(0.0), not null
#  distribution_misc_profits_amount          :decimal(20, 10)  default(0.0), not null
#  distribution_structure_costs_amount       :decimal(20, 10)  default(0.0), not null
#  distribution_withholding_tax_amount       :decimal(20, 10)  default(0.0), not null
#  distribution_recallable_amount            :decimal(20, 10)  default(0.0), not null
#  distribution_compensatory_interest_amount :decimal(20, 10)  default(0.0), not null
#  capital_call_gross_amount                 :decimal(20, 10)  default(0.0), not null
#  capital_call_compensatory_interest_amount :decimal(20, 10)  default(0.0), not null
#  capital_call_management_fees_amount       :decimal(20, 10)  default(0.0), not null
#  fund_cashflow_id                          :uuid
#  investor_id                               :uuid
#  created_at                                :datetime         not null
#  updated_at                                :datetime         not null
#
# Indexes
#
#  index_investor_cashflows_on_fund_cashflow_id  (fund_cashflow_id)
#  index_investor_cashflows_on_investor_id       (investor_id)
#
# Foreign Keys
#
#  fk_rails_...  (fund_cashflow_id => fund_cashflows.id)
#  fk_rails_...  (investor_id => investors.id)
#

# Defines the InvestorCashflow
class InvestorCashflow < ApplicationRecord
  include AASM

  belongs_to :fund_cashflow, inverse_of: :investor_cashflows, autosave: true, required: true
  belongs_to :investor, inverse_of: :investor_cashflows, autosave: true, required: true

  has_paper_trail(
    meta: {
      parent_item_id: proc { |investor_cashflow| investor_cashflow.fund_cashflow.fund_id },
      parent_item_type: 'Fund'
    },
    skip: SKIPPED_ATTRIBUTES
  )

  aasm do
    state :open, initial: true
    state :finished

    event :finish do
      transitions from: :open, to: :finished
    end
  end

  alias_attribute :state, :aasm_state

  def net_cashflow_amount
    distribution_total_amount - capital_call_total_amount
  end

  # rubocop:disable Metrics/AbcSize
  def distribution_total_amount
    distribution_reduction_amount +
      distribution_participation_profits_amount +
      distribution_dividends_amount +
      distribution_interest_amount +
      distribution_misc_profits_amount +
      distribution_structure_costs_amount +
      distribution_withholding_tax_amount +
      distribution_recallable_amount +
      distribution_compensatory_interest_amount
  end
  # rubocop:enable Metrics/AbcSize

  def capital_call_total_amount
    capital_call_gross_amount +
      capital_call_compensatory_interest_amount +
      capital_call_management_fees_amount
  end
end
