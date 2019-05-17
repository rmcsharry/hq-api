# frozen_string_literal: true

# == Schema Information
#
# Table name: investor_cashflows
#
#  aasm_state                                :string
#  capital_call_compensatory_interest_amount :decimal(20, 10)  default(0.0), not null
#  capital_call_gross_amount                 :decimal(20, 10)  default(0.0), not null
#  capital_call_management_fees_amount       :decimal(20, 10)  default(0.0), not null
#  created_at                                :datetime         not null
#  distribution_compensatory_interest_amount :decimal(20, 10)  default(0.0), not null
#  distribution_dividends_amount             :decimal(20, 10)  default(0.0), not null
#  distribution_interest_amount              :decimal(20, 10)  default(0.0), not null
#  distribution_misc_profits_amount          :decimal(20, 10)  default(0.0), not null
#  distribution_participation_profits_amount :decimal(20, 10)  default(0.0), not null
#  distribution_recallable_amount            :decimal(20, 10)  default(0.0), not null
#  distribution_repatriation_amount          :decimal(20, 10)  default(0.0), not null
#  distribution_structure_costs_amount       :decimal(20, 10)  default(0.0), not null
#  distribution_withholding_tax_amount       :decimal(20, 10)  default(0.0), not null
#  fund_cashflow_id                          :uuid
#  id                                        :uuid             not null, primary key
#  investor_id                               :uuid
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

RSpec.describe InvestorCashflow, type: :model, bullet: false do
  subject { create(:investor_cashflow, :capital_call, :distribution) }

  it { is_expected.to belong_to(:fund_cashflow).required }
  it { is_expected.to belong_to(:investor).required }

  it { is_expected.to respond_to :distribution_repatriation_amount }
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

  describe '#cashflow_document_context' do
    let(:fund) { create(:fund) }
    let!(:cashflow) { create(:fund_cashflow, fund: fund, number: 1) }
    let!(:investor) { create(:investor, :signed, fund: fund) }
    let!(:investor_cashflow) do
      create(
        :investor_cashflow,
        capital_call_gross_amount: cashflow_type == :distribution ? 0 : 1,
        distribution_dividends_amount: cashflow_type == :distribution ? 1 : 0,
        fund_cashflow: cashflow,
        investor: investor
      )
    end

    context 'as a capital_call' do
      let!(:cashflow_type) { :capital_call }

      it 'returns the capital_call context' do
        expect(investor_cashflow.cashflow_document_context.keys).to(
          match_array(
            %i[
              current_date
              fund
              fund_cashflow
              investor
              investor_cashflow
            ]
          )
        )
      end
    end

    context 'as a distribution' do
      let!(:cashflow_type) { :distribution }

      it 'returns the distribution context' do
        expect(investor_cashflow.cashflow_document_context.keys).to(
          match_array(
            %i[
              current_date
              fund
              fund_cashflow
              investor
              investor_cashflow
            ]
          )
        )
      end
    end
  end

  describe '#cashflow_document', bullet: false do
    let(:current_user) { create(:user) }
    let(:fund) { create(:fund) }
    let!(:investor) { create(:investor, :signed, fund: fund) }
    let!(:fund_cashflow) { create(:fund_cashflow, fund: fund) }
    let!(:investor_cashflow) do
      create(
        :investor_cashflow,
        capital_call_gross_amount: 1,
        distribution_dividends_amount: 0,
        fund_cashflow: fund_cashflow,
        investor: investor
      )
    end
    let(:valid_template_name) { 'Kapitalabruf_Vorlage.docx' }
    let(:invalid_template_name) { 'hqtrust_sample_unprivileged_access.docx' }
    let!(:valid_template) do
      doc = create(
        :fund_template_document,
        category: :fund_capital_call_template,
        owner: fund
      )
      doc.file.attach(
        io: File.open(Rails.root.join('spec', 'fixtures', 'docx', valid_template_name)),
        filename: 'sample.docx',
        content_type: Mime[:docx].to_s
      )
      doc
    end
    let!(:invalid_template_file) do
      {
        io: File.open(Rails.root.join('spec', 'fixtures', 'docx', invalid_template_name)),
        filename: 'sample.docx',
        content_type: Mime[:docx].to_s
      }
    end

    it 'is generated and persisted if absent' do
      generated_document = investor_cashflow.cashflow_document(current_user)
      document_content = docx_document_content(generated_document.file.download)

      expect(document_content).to include(fund.name)

      valid_template.file.attach(invalid_template_file)
      subsequently_retrieved_document = investor_cashflow.cashflow_document(current_user)
      subsequent_document_content = docx_document_content(subsequently_retrieved_document.file.download)

      expect(subsequent_document_content).to eq(document_content)
    end
  end
end
