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
  include_examples 'state_transitions'

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
    let(:generated_cashflow_document) { create(:generated_cashflow_document) }
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
    let(:other_template_name) { 'zoomed_scrolled.docx' }
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
    let!(:other_template_file) do
      {
        io: File.open(Rails.root.join('spec', 'fixtures', 'docx', other_template_name)),
        filename: 'sample.docx',
        content_type: Mime[:docx].to_s
      }
    end

    it 'is generated and persisted if absent' do
      generated_document = investor_cashflow.cashflow_document(current_user: current_user)
      document_content = docx_document_content(generated_document.file.download)

      expect(document_content).to include(fund.name)
      expect(document_content).to include('Kapitalabruf (Gesamtbetrag)')
      expect(document_content).not_to include('Ausschüttung (Gesamtbetrag)')
      expect(document_content).not_to include('Davon Sonstige Erträge')

      valid_template.file.attach(other_template_file)
      subsequently_retrieved_document = investor_cashflow.cashflow_document(current_user: current_user)
      subsequent_document_content = docx_document_content(subsequently_retrieved_document.file.download)

      expect(subsequent_document_content).to eq(document_content)
    end

    it 'destroys the existing cashflow document' do
      allow(investor_cashflow).to receive(:find_generated_document_by_category) { generated_cashflow_document }
      expect(generated_cashflow_document).to receive(:destroy!)
      investor_cashflow.cashflow_document(current_user: current_user, regenerate: true)
    end

    it 'creates a new generated cashflow document' do
      new_generated_cashflow_document = investor_cashflow.cashflow_document(
        current_user: current_user, regenerate: true
      )
      expect(generated_cashflow_document.id).not_to eq(new_generated_cashflow_document.id)
    end
  end

  describe 'investor called and open amounts and percentages' do
    let(:fund) { create(:fund) }
    let!(:investor) { create(:investor, :signed, fund: fund, amount_total: 5_000_000) }
    let!(:fund_cashflow1) { create(:fund_cashflow, fund: fund, number: 1) }
    let!(:investor_cashflow1) do
      create(
        :investor_cashflow,
        capital_call_gross_amount: 1_000_000,
        distribution_recallable_amount: 200_000,
        fund_cashflow: fund_cashflow1,
        investor: investor
      )
    end
    let!(:fund_cashflow2) { create(:fund_cashflow, fund: fund, number: 2) }
    let!(:investor_cashflow2) do
      create(
        :investor_cashflow,
        capital_call_gross_amount: 1_500_000,
        distribution_recallable_amount: 100_000,
        fund_cashflow: fund_cashflow2,
        investor: investor
      )
    end
    let!(:fund_cashflow3) { create(:fund_cashflow, fund: fund, number: 3) }
    let!(:investor_cashflow3) do
      create(
        :investor_cashflow,
        capital_call_gross_amount: 2_000_000,
        distribution_recallable_amount: 0,
        fund_cashflow: fund_cashflow3,
        investor: investor
      )
    end

    context 'for cashflow #1' do
      it 'calculates the called and open amounts correctly' do
        expect(investor_cashflow1.investor_called_amount).to eq 1_000_000.0
        expect(investor_cashflow1.investor_called_percentage).to eq 0.2
        expect(investor_cashflow1.investor_open_amount).to eq 4_200_000.0
        expect(investor_cashflow1.investor_open_percentage).to eq 0.84
        expect(investor_cashflow1.investor_recallable_amount).to eq 200_000.0
      end
    end

    context 'for cashflow #2' do
      it 'calculates the called and open amounts correctly' do
        expect(investor_cashflow2.investor_called_amount).to eq 2_500_000.0
        expect(investor_cashflow2.investor_called_percentage).to eq 0.5
        expect(investor_cashflow2.investor_open_amount).to eq 2_800_000.0
        expect(investor_cashflow2.investor_open_percentage.to_f).to eq 0.56 # for some weird quirk, it requires .to_f
        expect(investor_cashflow2.investor_recallable_amount).to eq 300_000.0
      end
    end

    context 'for cashflow #3' do
      it 'calculates the called and open amounts correctly' do
        expect(investor_cashflow3.investor_called_amount).to eq 4_500_000.0
        expect(investor_cashflow3.investor_called_percentage).to eq 0.9
        expect(investor_cashflow3.investor_open_amount).to eq 800_000.0
        expect(investor_cashflow3.investor_open_percentage).to eq 0.16
        expect(investor_cashflow3.investor_recallable_amount).to eq 300_000.0
      end
    end

    context 'for investor amount total being 0' do
      let!(:investor) { create(:investor, :signed, fund: fund, amount_total: 0) }

      it 'calculates the called and open amounts correctly' do
        expect(investor_cashflow1.investor_called_amount).to eq 1_000_000.0
        expect(investor_cashflow1.investor_called_percentage).to eq 1.0
        expect(investor_cashflow1.investor_open_amount).to eq(-800_000.0)
        expect(investor_cashflow1.investor_open_percentage).to eq 0.0
        expect(investor_cashflow1.investor_recallable_amount).to eq 200_000.0
      end
    end
  end
end
