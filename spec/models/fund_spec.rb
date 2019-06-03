# frozen_string_literal: true

# == Schema Information
#
# Table name: funds
#
#  aasm_state                                :string           not null
#  capital_management_company_id             :uuid
#  comment                                   :text
#  commercial_register_number                :string
#  commercial_register_office                :string
#  created_at                                :datetime         not null
#  currency                                  :string
#  de_central_bank_id                        :string
#  de_foreign_trade_regulations_id           :string
#  duration                                  :integer
#  duration_extension                        :integer
#  global_intermediary_identification_number :string
#  id                                        :uuid             not null, primary key
#  issuing_year                              :integer
#  legal_address_id                          :uuid
#  name                                      :string           not null
#  primary_contact_address_id                :uuid
#  psplus_asset_id                           :string
#  region                                    :string
#  strategy                                  :string
#  tax_id                                    :string
#  tax_office                                :string
#  type                                      :string
#  updated_at                                :datetime         not null
#  us_employer_identification_number         :string
#
# Indexes
#
#  index_funds_on_capital_management_company_id  (capital_management_company_id)
#  index_funds_on_legal_address_id               (legal_address_id)
#  index_funds_on_primary_contact_address_id     (primary_contact_address_id)
#
# Foreign Keys
#
#  fk_rails_...  (capital_management_company_id => contacts.id)
#  fk_rails_...  (legal_address_id => addresses.id)
#  fk_rails_...  (primary_contact_address_id => addresses.id)
#

require 'rails_helper'

RSpec.describe Fund, type: :model do
  it { is_expected.to belong_to(:capital_management_company).optional }
  it { is_expected.to belong_to(:legal_address).optional }
  it { is_expected.to belong_to(:primary_contact_address).optional }
  it { is_expected.to have_many(:addresses) }
  it { is_expected.to have_many(:bank_accounts) }
  it { is_expected.to have_many(:documents) }
  it { is_expected.to have_many(:fund_cashflows) }
  it { is_expected.to have_many(:fund_reports) }
  it { is_expected.to have_many(:fund_templates) }
  it { is_expected.to have_many(:investor_cashflows) }
  it { is_expected.to have_many(:investor_reports) }
  it { is_expected.to have_many(:investors) }

  describe '#aasm_state' do
    it { is_expected.to respond_to(:aasm_state) }
    it { is_expected.to respond_to(:state) }
    it { is_expected.to validate_presence_of(:state) }
  end

  describe '#commercial_register_office' do
    context 'commercial_register_number is present' do
      subject { build(:fund, commercial_register_number: 'HRB 123456 B') }

      it 'validates presence' do
        expect(subject).to validate_presence_of(:commercial_register_office)
      end
    end
  end

  describe '#commercial_register_number' do
    context 'commercial_register_office is present' do
      subject { build(:fund, commercial_register_office: 'Amtsgericht Berlin-Charlottenburg') }

      it 'validates presence' do
        expect(subject).to validate_presence_of(:commercial_register_number)
      end
    end
  end

  describe '#currency' do
    it { is_expected.to respond_to(:currency) }
    it { is_expected.to validate_presence_of(:currency) }
  end

  describe '#de_central_bank_id' do
    it { is_expected.to respond_to(:de_central_bank_id) }

    context 'validates format' do
      let(:valid_examples) { ['01234567', '12345678', '65279318', ''] }
      let(:invalid_examples) { ['123456789', 'a', 'a123456', '1 345678', '12-654', '00000000', '1.345678'] }

      it { is_expected.to allow_values(*valid_examples).for(:de_central_bank_id) }
      it { is_expected.not_to allow_values(*invalid_examples).for(:de_central_bank_id) }
    end
  end

  describe '#de_foreign_trade_regulations_id' do
    it { is_expected.to respond_to(:de_foreign_trade_regulations_id) }

    context 'validates format' do
      let(:valid_examples) { ['01234', '12345', '52793', ''] }
      let(:invalid_examples) { ['123456', 'a', 'a1234', '1 345', '12-65', '00000', '1.345'] }

      it { is_expected.to allow_values(*valid_examples).for(:de_foreign_trade_regulations_id) }
      it { is_expected.not_to allow_values(*invalid_examples).for(:de_foreign_trade_regulations_id) }
    end
  end

  describe '#duration' do
    it { is_expected.to respond_to(:duration) }
    it { is_expected.to validate_presence_of(:duration) }
  end

  describe '#duration_extension' do
    it { is_expected.to respond_to(:duration_extension) }
    it { is_expected.to validate_presence_of(:duration_extension) }
  end

  describe '#global_intermediary_identification_number' do
    it { is_expected.to respond_to(:global_intermediary_identification_number) }

    context 'validates format' do
      let(:valid_examples) { ['0123456789123456789', '1234567890123456789', '5279318033432345701', ''] }
      let(:invalid_examples) do
        ['12345678901234567890', # 20 digits (too long, expects exactly 19)
         'a', # 1 letter
         'a12345678asdfj12345', # 19 chars but not all digits
         '0 23456789999999999', # 19 length, all digits but a space
         '12-6543219999999999', # 19 length, all digits but a dash
         '0000000000000000000', # 19 digits but all zeros
         '1.34567890123456789'] # 19 length, all digits but deimcal point
      end

      it { is_expected.to allow_values(*valid_examples).for(:global_intermediary_identification_number) }
      it { is_expected.not_to allow_values(*invalid_examples).for(:global_intermediary_identification_number) }
    end
  end

  describe '#issuing_year' do
    it { is_expected.to respond_to(:issuing_year) }
    it { is_expected.to validate_presence_of(:issuing_year) }
  end

  describe '#name' do
    it { is_expected.to respond_to(:name) }
    it { is_expected.to validate_presence_of(:name) }
  end

  describe '#psplus_asset_id' do
    it { is_expected.to respond_to(:psplus_asset_id) }
    it { is_expected.to validate_length_of(:psplus_asset_id).is_at_most(15) }
  end

  describe '#region' do
    it { is_expected.to enumerize(:region) }
    it { is_expected.to validate_presence_of(:region) }
  end

  describe '#strategy' do
    it { is_expected.to validate_presence_of(:strategy) }
  end

  describe '#tax_id' do
    it { is_expected.to respond_to(:tax_id) }
  end

  describe '#tax_office' do
    it { is_expected.to respond_to(:tax_office) }
  end

  describe '#type' do
    it { is_expected.to validate_presence_of(:type) }
  end

  describe '#us_employer_identification_number' do
    it { is_expected.to respond_to(:us_employer_identification_number) }

    context 'validates format' do
      let(:valid_examples) { ['012345678', '123456789', '527931803', ''] }
      let(:invalid_examples) { ['1234567890', 'a', 'a12345678', '0 2345678', '12-654321', '000000000', '1.3456789'] }

      it { is_expected.to allow_values(*valid_examples).for(:us_employer_identification_number) }
      it { is_expected.not_to allow_values(*invalid_examples).for(:us_employer_identification_number) }
    end
  end

  describe '#to_s' do
    subject { build(:fund, name: 'HQT Merkur Multi IV GmbH & Co. KG') }

    it 'serializes simple record' do
      expect(subject.to_s).to eq('HQT Merkur Multi IV GmbH & Co. KG')
    end
  end

  context 'fund KPIs', bullet: false do
    subject { create(:fund) }
    let!(:investor1) { create(:investor, :signed, fund: subject, amount_total: '1000000.99') }
    let!(:investor2) { create(:investor, :signed, fund: subject, amount_total: '3500000') }
    let!(:investor3) { create(:investor, fund: subject, amount_total: '2750000.0') }
    let!(:capital_call1) do
      create(
        :investor_cashflow, investor: investor1, fund: subject,
                            capital_call_gross_amount: '550000.25',
                            capital_call_management_fees_amount: '12000'
      )
    end
    let!(:capital_call2) do
      create(
        :investor_cashflow, investor: investor1, fund: subject,
                            capital_call_gross_amount: '250000',
                            capital_call_compensatory_interest_amount: '10000'
      )
    end
    let!(:capital_call3) do
      create(
        :investor_cashflow, investor: investor2, fund: subject,
                            capital_call_gross_amount: '1430000.84',
                            distribution_repatriation_amount: '750000'
      )
    end
    let!(:distribution1) do
      create(
        :investor_cashflow, investor: investor1, fund: subject,
                            capital_call_compensatory_interest_amount: '10000',
                            distribution_repatriation_amount: '750000',
                            distribution_recallable_amount: '34000.23'
      )
    end
    let!(:distribution2) do
      create(
        :investor_cashflow, investor: investor2, fund: subject,
                            capital_call_compensatory_interest_amount: '20000',
                            distribution_repatriation_amount: '10000',
                            distribution_participation_profits_amount: '10000',
                            distribution_dividends_amount: '10000',
                            distribution_interest_amount: '10000',
                            distribution_withholding_tax_amount: '10000',
                            distribution_recallable_amount: '10000',
                            distribution_compensatory_interest_amount: '10000'
      )
    end
    let!(:distribution3) do
      create(
        :investor_cashflow, investor: investor2, fund: subject,
                            distribution_repatriation_amount: '35000',
                            distribution_participation_profits_amount: '35000',
                            distribution_dividends_amount: '35000',
                            distribution_interest_amount: '35000',
                            distribution_misc_profits_amount: '35000',
                            distribution_structure_costs_amount: '35000',
                            distribution_withholding_tax_amount: '35000',
                            distribution_recallable_amount: '35000',
                            distribution_compensatory_interest_amount: '35000'
      )
    end

    describe '#total_signed_amount' do
      it 'counts only signed investors amount' do
        expect(subject.total_signed_amount).to eq 4_500_000.99
      end
    end

    describe '#total_called_amount' do
      it 'calculates the sum of all capital calls' do
        expect(subject.total_called_amount).to eq 2_282_001.09
      end
    end

    describe '#total_open_amount' do
      it 'calculates the amount that is still open' do
        expect(subject.total_open_amount).to eq 2_297_000.13
      end
    end

    describe '#total_distributions_amount' do
      it 'calculates the sum of all distributions' do
        expect(subject.total_distributions_amount).to eq 1_919_000.23
      end
    end

    describe '#total_recallable_amount' do
      it 'calculates the sum of all recallable distributions' do
        expect(subject.total_recallable_amount).to eq 79_000.23
      end
    end
  end

  describe '#cashflow_template', bullet: false do
    let!(:fund) { create(:fund) }
    let!(:cashflow) { create(:fund_cashflow, fund: fund, number: 1) }
    let!(:investor) { create(:investor, :signed, fund: fund) }
    let!(:template) do
      category = cashflow_type == :distribution ? :fund_distribution_template : :fund_capital_call_template
      doc = create(:fund_template_document, category: category, owner: fund)
      doc.file.attach(
        io: File.open(Rails.root.join('spec', 'fixtures', 'docx', document_name)),
        filename: 'sample.docx',
        content_type: Mime[:docx].to_s
      )
      doc
    end
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

      context 'with missing template' do
        let!(:template) { nil }

        it 'throws an exception' do
          expect do
            fund.cashflow_template(cashflow)
          end.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context 'with existing template' do
        let(:document_name) { 'Ausschuettung_Vorlage.docx' }

        it 'returns the template' do
          expect(fund.cashflow_template(cashflow)).to eq(template)
        end
      end
    end

    context 'as a distribution' do
      let!(:cashflow_type) { :distribution }

      context 'with missing template' do
        let!(:template) { nil }

        it 'throws an exception' do
          expect do
            fund.cashflow_template(cashflow)
          end.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context 'with existing template' do
        let(:document_name) { 'Kapitalabruf_Vorlage.docx' }

        it 'returns the template' do
          expect(fund.cashflow_template(cashflow)).to eq(template)
        end
      end
    end
  end

  describe '#quarterly_report_template' do
    let!(:fund) { create(:fund) }
    let!(:document_category) { :fund_quarterly_report_template }
    let!(:template) do
      doc = create(:fund_template_document, category: document_category, owner: fund)
      doc.file.attach(
        io: File.open(Rails.root.join('spec', 'fixtures', 'docx', document_name)),
        filename: 'sample.docx',
        content_type: Mime[:docx].to_s
      )
      doc
    end

    context 'with missing template' do
      let!(:template) { nil }

      it 'throws an exception' do
        expect do
          fund.quarterly_report_template
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'with existing template' do
      let(:document_name) { 'Quartalsbericht_Vorlage.docx' }

      it 'returns the template' do
        expect(fund.quarterly_report_template).to eq(template)
      end
    end
  end

  describe '#subscription_agreement_template' do
    let!(:fund) { create(:fund) }
    let!(:document_category) { :fund_subscription_agreement_template }
    let!(:template) do
      doc = create(:fund_template_document, category: document_category, owner: fund)
      doc.file.attach(
        io: File.open(Rails.root.join('spec', 'fixtures', 'docx', document_name)),
        filename: 'sample.docx',
        content_type: Mime[:docx].to_s
      )
      doc
    end

    context 'with missing template' do
      let!(:template) { nil }

      it 'throws an exception' do
        expect do
          fund.subscription_agreement_template
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'with existing template' do
      let(:document_name) { 'Zeichnungsschein_Vorlage.docx' }

      it 'returns the template' do
        expect(fund.subscription_agreement_template).to eq(template)
      end
    end
  end
end
