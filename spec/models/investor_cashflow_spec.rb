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

require 'rails_helper'

RSpec.describe InvestorCashflow, type: :model do
  subject { create(:investor_cashflow, :capital_call, :distribution) }

  it { is_expected.to belong_to(:fund_cashflow).required }
  it { is_expected.to belong_to(:investor).required }

  it { is_expected.to respond_to :distribution_reduction_amount }
  it { is_expected.to respond_to :distribution_participation_profits_amount }
  it { is_expected.to respond_to :distribution_dividends_amount }
  it { is_expected.to respond_to :distribution_interest_amount }
  it { is_expected.to respond_to :distribution_misc_profits_amount }
  it { is_expected.to respond_to :distribution_structure_costs_amount }
  it { is_expected.to respond_to :distribution_withholding_tax_amount }
  it { is_expected.to respond_to :distribution_recallable_amount }
  it { is_expected.to respond_to :distribution_compensatory_interest_amount }
  it { is_expected.to respond_to :capital_call_gross_amount }
  it { is_expected.to respond_to :capital_call_compensatory_interest_amount }
  it { is_expected.to respond_to :capital_call_management_fees_amount }

  describe '#aasm_state' do
    it { is_expected.to respond_to :aasm_state }
    it { is_expected.to respond_to :state }
  end

  describe '#net_cashflow_amount' do
    it 'is calculated based on distribution_total_amount and capital_call_total_amount' do
      expect(subject.net_cashflow_amount).to eq 600_000
    end
  end

  describe '#distribution_total_amount' do
    it 'is the sum of all distribution amounts' do
      expect(subject.distribution_total_amount).to eq 900_000
    end
  end

  describe '#capital_call_total_amount' do
    it 'is the sum of all capital call amounts' do
      expect(subject.capital_call_total_amount).to eq 300_000
    end
  end
end
