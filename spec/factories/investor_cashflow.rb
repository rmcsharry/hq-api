# frozen_string_literal: true

FactoryBot.define do
  factory :investor_cashflow do
    transient do
      fund { build(:fund) }
    end

    investor { build(:investor, fund: fund) }
    fund_cashflow { build(:fund_cashflow, fund: fund) }
    aasm_state 'open'

    trait :capital_call do
      capital_call_compensatory_interest_amount 100_000
      capital_call_gross_amount 100_000
      capital_call_management_fees_amount 100_000
    end

    trait :distribution do
      distribution_compensatory_interest_amount 100_000
      distribution_dividends_amount 100_000
      distribution_interest_amount 100_000
      distribution_misc_profits_amount 100_000
      distribution_participation_profits_amount 100_000
      distribution_recallable_amount 100_000
      distribution_reduction_amount 100_000
      distribution_structure_costs_amount 100_000
      distribution_withholding_tax_amount 100_000
    end
  end
end
