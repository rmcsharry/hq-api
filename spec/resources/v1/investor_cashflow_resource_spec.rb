# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::InvestorCashflowResource, type: :resource do
  let(:investor_cashflow) { create(:investor_cashflow) }
  subject { described_class.new(investor_cashflow, {}) }

  it { is_expected.to have_attribute :capital_call_compensatory_interest_amount }
  it { is_expected.to have_attribute :capital_call_gross_amount }
  it { is_expected.to have_attribute :capital_call_management_fees_amount }
  it { is_expected.to have_attribute :capital_call_total_amount }
  it { is_expected.to have_attribute :distribution_compensatory_interest_amount }
  it { is_expected.to have_attribute :distribution_dividends_amount }
  it { is_expected.to have_attribute :distribution_interest_amount }
  it { is_expected.to have_attribute :distribution_misc_profits_amount }
  it { is_expected.to have_attribute :distribution_participation_profits_amount }
  it { is_expected.to have_attribute :distribution_recallable_amount }
  it { is_expected.to have_attribute :distribution_reduction_amount }
  it { is_expected.to have_attribute :distribution_structure_costs_amount }
  it { is_expected.to have_attribute :distribution_total_amount }
  it { is_expected.to have_attribute :distribution_withholding_tax_amount }
  it { is_expected.to have_attribute :net_cashflow_amount }
  it { is_expected.to have_attribute :state }

  it { is_expected.to have_one :investor }
  it { is_expected.to have_one :fund_cashflow }

  it { is_expected.to filter :fund_cashflow_id }
end
