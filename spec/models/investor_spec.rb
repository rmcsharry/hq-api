# frozen_string_literal: true

# == Schema Information
#
# Table name: investors
#
#  aasm_state             :string           not null
#  amount_total           :decimal(20, 2)
#  bank_account_id        :uuid
#  capital_account_number :string
#  created_at             :datetime         not null
#  fund_id                :uuid
#  id                     :uuid             not null, primary key
#  investment_date        :datetime
#  mandate_id             :uuid
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_investors_on_fund_id     (fund_id)
#  index_investors_on_mandate_id  (mandate_id)
#
# Foreign Keys
#
#  fk_rails_...  (bank_account_id => bank_accounts.id)
#  fk_rails_...  (fund_id => funds.id)
#  fk_rails_...  (mandate_id => mandates.id)
#

require 'rails_helper'

RSpec.describe Investor, type: :model do
  include_examples 'state_transitions'

  it { is_expected.to validate_presence_of(:amount_total) }
  it { is_expected.to validate_presence_of(:bank_account) }
  it { is_expected.to validate_presence_of(:fund) }
  it { is_expected.to validate_presence_of(:mandate) }

  it { is_expected.to belong_to(:bank_account) }
  it { is_expected.to belong_to(:fund) }
  it { is_expected.to belong_to(:mandate) }
  it { is_expected.to have_many(:documents) }
  it { is_expected.to have_one(:contact_address) }
  it { is_expected.to have_one(:fund_subscription_agreement) }
  it { is_expected.to have_one(:legal_address) }
  it { is_expected.to have_one(:primary_contact) }
  it { is_expected.to have_one(:primary_owner) }
  it { is_expected.to have_one(:secondary_contact) }

  it { is_expected.to respond_to(:contact_address) }
  it { is_expected.to respond_to(:contact_salutation_primary_contact) }
  it { is_expected.to respond_to(:contact_salutation_primary_owner) }
  it { is_expected.to respond_to(:contact_salutation_secondary_contact) }
  it { is_expected.to respond_to(:legal_address) }
  it { is_expected.to respond_to(:primary_contact) }
  it { is_expected.to respond_to(:primary_owner) }
  it { is_expected.to respond_to(:secondary_contact) }

  describe '#sign' do
    let(:investor) { create :investor }

    it 'transitions state from :created to :signed' do
      investor.state = 'created'
      investor.sign
      expect(investor.state).to eq('signed')
    end
  end

  describe '#investment_date' do
    let(:investor) { create :investor, state: :created }

    context 'when state is :created' do
      it 'is not validated for presence' do
        investor.investment_date = nil
        expect(investor.valid?).to eq(true)
      end

      it 'is set if investor becomes signed' do
        investor.investment_date = nil
        expect(investor.investment_date).to eq(nil)
        investor.sign
        expect(investor.reload.investment_date).not_to eq(nil)
      end
    end

    context 'when state is :signed' do
      it 'is validated for presence' do
        investor.sign
        investor.investment_date = nil
        expect(investor.valid?).to eq(false)
      end
    end
  end

  describe '#fund_subscription_agreement' do
    let(:investor) { create :investor, state: :created }

    context 'when state is :created' do
      it 'is not validated for presence' do
        investor.documents = []
        expect(investor.valid?).to eq(true)
      end

      it 'is not present' do
        expect(investor.fund_subscription_agreement).to eq(nil)
      end

      context 'and a fund_subscription_agreement is created' do
        let!(:fund_subscription_agreement) { create :fund_subscription_agreement, owner: investor }

        it 'transitions to :signed', bullet: false do
          expect(investor.fund_subscription_agreement).to eq(fund_subscription_agreement)
          expect(investor.state).to eq('signed')
        end
      end
    end

    context 'when state is :signed' do
      it 'is validated for presence' do
        investor.sign
        investor.documents = []
        expect(investor.valid?).to eq(false)
      end
    end
  end

  describe '#aasm_state' do
    it { is_expected.to respond_to(:aasm_state) }
    it { is_expected.to respond_to(:state) }
  end

  describe '#current_value' do
    it { is_expected.to respond_to(:current_value) }

    # TODO: Add meaningful specs
  end

  describe '#tvpi' do
    it { is_expected.to respond_to(:tvpi) }

    # TODO: Add meaningful specs
  end

  describe '#dpi' do
    it { is_expected.to respond_to(:dpi) }

    # TODO: Add meaningful specs
  end

  describe '#irr' do
    it { is_expected.to respond_to(:irr) }

    # TODO: Add meaningful specs
  end

  context 'investor KPIs', bullet: false do
    subject { create(:investor, :signed, fund: fund, amount_total: '4500000.99') }
    let(:fund) { create(:fund) }
    let!(:capital_call1) do
      create(
        :investor_cashflow, investor: subject, fund: fund,
                            capital_call_gross_amount: '550000.25',
                            capital_call_management_fees_amount: '12000'
      )
    end
    let!(:capital_call2) do
      create(
        :investor_cashflow, investor: subject, fund: fund,
                            capital_call_gross_amount: '250000',
                            capital_call_compensatory_interest_amount: '10000'
      )
    end
    let!(:capital_call3) do
      create(
        :investor_cashflow, investor: subject, fund: fund,
                            capital_call_gross_amount: '1430000.84',
                            distribution_repatriation_amount: '750000'
      )
    end
    let!(:distribution1) do
      create(
        :investor_cashflow, investor: subject, fund: fund,
                            capital_call_compensatory_interest_amount: '10000',
                            distribution_repatriation_amount: '750000',
                            distribution_recallable_amount: '34000.23'
      )
    end
    let!(:distribution2) do
      create(
        :investor_cashflow, investor: subject, fund: fund,
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
        :investor_cashflow, investor: subject, fund: fund,
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

    describe '#amount_total' do
      it 'return the total amount of the investor' do
        expect(subject.amount_total).to eq 4_500_000.99
      end
    end

    describe '#amount_called' do
      it 'calculates the sum of all capital calls' do
        expect(subject.amount_called).to eq 2_282_001.09
      end
    end

    describe '#amount_open' do
      it 'calculates the amount that is still open' do
        expect(subject.amount_open).to eq 2_297_000.13
      end
    end

    describe '#amount_recallable' do
      it 'calculates the sum of all recallable distributions' do
        expect(subject.amount_recallable).to eq 79_000.23
      end
    end

    describe '#amount_total_distribution' do
      it 'calculates the sum of all distributions' do
        expect(subject.amount_total_distribution).to eq 1_919_000.23
      end
    end
  end

  describe '#subscription_agreement_document_context', bullet: false do
    let(:fund) { create(:fund) }
    let!(:investor) { create(:investor, :signed, fund: fund) }

    it 'returns the subscription_agreement_document context' do
      expect(investor.subscription_agreement_document_context.keys).to(
        match_array(
          %i[
            current_date
            fund
            investor
          ]
        )
      )
    end
  end

  describe '#subscription_agreement_document', bullet: false do
    let(:current_user) { create(:user) }
    let(:fund) { create(:fund) }
    let!(:investor) { create(:investor, fund: fund) }
    let(:valid_template_name) { 'Zeichnungsschein_Vorlage.docx' }
    let(:other_template_name) { 'zoomed_scrolled.docx' }
    let(:generated_subscription_agreement) { create(:generated_subscription_agreement_document) }
    let!(:valid_template) do
      doc = create(
        :fund_template_document,
        category: :fund_subscription_agreement_template,
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
      generated_document = investor.subscription_agreement_document(current_user: current_user)
      document_content = docx_document_content(generated_document.file.download)

      expect(document_content).to include(fund.name)

      valid_template.file.attach(other_template_file)
      subsequently_retrieved_document = investor.subscription_agreement_document(current_user: current_user)
      subsequent_document_content = docx_document_content(subsequently_retrieved_document.file.download)

      expect(subsequent_document_content).to eq(document_content)
    end

    it 'destroys the existing subscription agreement' do
      allow(investor).to receive(:find_generated_document_by_category) { generated_subscription_agreement }
      expect(generated_subscription_agreement).to receive(:destroy!)
      investor.subscription_agreement_document(current_user: current_user, regenerate: true)
    end

    it 'creates a new generated subscription agreement' do
      new_generated_subscription_agreement = investor.subscription_agreement_document(
        current_user: current_user, regenerate: true
      )
      expect(generated_subscription_agreement.id).not_to eq(new_generated_subscription_agreement.id)
    end

    context 'when investor is "signed"' do
      let(:current_user) { build(:user) }
      let(:investor) { build(:investor, :signed) }

      it 'returns the signed fund subscription agreement' do
        expect(investor.subscription_agreement_document(current_user: current_user)).to(
          be(investor.fund_subscription_agreement)
        )
      end
    end
  end

  describe '#bank_account' do
    subject { build(:investor, mandate: mandate, bank_account: bank_account) }

    let(:mandate) { build(:mandate) }

    context 'belongs to mandate' do
      let(:bank_account) { build(:bank_account, owner: mandate) }

      it 'is valid' do
        expect(subject).to be_valid
      end
    end

    context 'does not belong to mandate' do
      let(:bank_account) { build(:bank_account) }

      it 'is invalid' do
        expect(subject).to be_invalid
      end
    end
  end
end
