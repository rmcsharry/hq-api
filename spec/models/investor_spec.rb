# frozen_string_literal: true

# == Schema Information
#
# Table name: investors
#
#  id                                   :uuid             not null, primary key
#  fund_id                              :uuid
#  mandate_id                           :uuid
#  legal_address_id                     :uuid
#  contact_address_id                   :uuid
#  contact_email_id                     :uuid
#  contact_phone_id                     :uuid
#  bank_account_id                      :uuid
#  primary_owner_id                     :uuid
#  aasm_state                           :string           not null
#  investment_date                      :datetime
#  amount_total                         :decimal(20, 2)
#  created_at                           :datetime         not null
#  updated_at                           :datetime         not null
#  primary_contact_id                   :uuid
#  secondary_contact_id                 :uuid
#  capital_account_number               :string
#  contact_salutation_primary_owner     :boolean
#  contact_salutation_primary_contact   :boolean
#  contact_salutation_secondary_contact :boolean
#
# Indexes
#
#  index_investors_on_fund_id               (fund_id)
#  index_investors_on_mandate_id            (mandate_id)
#  index_investors_on_primary_contact_id    (primary_contact_id)
#  index_investors_on_secondary_contact_id  (secondary_contact_id)
#
# Foreign Keys
#
#  fk_rails_...  (bank_account_id => bank_accounts.id)
#  fk_rails_...  (contact_address_id => addresses.id)
#  fk_rails_...  (contact_email_id => contact_details.id)
#  fk_rails_...  (contact_phone_id => contact_details.id)
#  fk_rails_...  (fund_id => funds.id)
#  fk_rails_...  (legal_address_id => addresses.id)
#  fk_rails_...  (mandate_id => mandates.id)
#  fk_rails_...  (primary_contact_id => contacts.id)
#  fk_rails_...  (primary_owner_id => contacts.id)
#  fk_rails_...  (secondary_contact_id => contacts.id)
#

require 'rails_helper'

RSpec.describe Investor, type: :model do
  it { is_expected.to validate_presence_of(:amount_total) }
  it { is_expected.to validate_presence_of(:bank_account) }
  it { is_expected.to validate_presence_of(:contact_address) }
  it { is_expected.to validate_presence_of(:contact_email) }
  it { is_expected.to validate_presence_of(:contact_phone) }
  it { is_expected.to validate_presence_of(:fund) }
  it { is_expected.to validate_presence_of(:legal_address) }
  it { is_expected.to validate_presence_of(:mandate) }

  it { is_expected.to belong_to(:bank_account) }
  it { is_expected.to belong_to(:contact_address) }
  it { is_expected.to belong_to(:contact_email) }
  it { is_expected.to belong_to(:contact_phone) }
  it { is_expected.to belong_to(:fund) }
  it { is_expected.to belong_to(:legal_address) }
  it { is_expected.to belong_to(:mandate) }
  it { is_expected.to belong_to(:primary_owner) }
  it { is_expected.to have_many(:documents) }
  it { is_expected.to have_one(:fund_subscription_agreement) }
  it { is_expected.to belong_to(:primary_contact).optional }
  it { is_expected.to belong_to(:secondary_contact).optional }

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
    let(:invalid_template_name) { 'hqtrust_sample_unprivileged_access.docx' }
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
    let!(:invalid_template_file) do
      {
        io: File.open(Rails.root.join('spec', 'fixtures', 'docx', invalid_template_name)),
        filename: 'sample.docx',
        content_type: Mime[:docx].to_s
      }
    end

    it 'is generated and persisted if absent' do
      generated_document = investor.subscription_agreement_document(current_user)
      document_content = docx_document_content(generated_document.file.download)

      expect(document_content).to include(fund.name)

      valid_template.file.attach(invalid_template_file)
      subsequently_retrieved_document = investor.subscription_agreement_document(current_user)
      subsequent_document_content = docx_document_content(subsequently_retrieved_document.file.download)

      expect(subsequent_document_content).to eq(document_content)
    end

    context 'when investor is "signed"' do
      let(:current_user) { build(:user) }
      let(:investor) { build(:investor, :signed) }

      it 'returns the signed fund subscription agreement' do
        expect(investor.subscription_agreement_document(current_user)).to be(investor.fund_subscription_agreement)
      end
    end
  end

  describe '#regenerated_subscription_agreement_document' do
    let(:current_user) { build(:user) }
    let(:generated_subscription_agreement) { create(:generated_subscription_agreement_document) }
    let(:investor) { generated_subscription_agreement.owner }
    let!(:fund) { create(:fund, investors: [investor]) }
    let!(:template) do
      doc = create(
        :fund_template_document,
        category: :fund_subscription_agreement_template,
        owner: fund
      )
      doc.file.attach(
        io: File.open(Rails.root.join('spec', 'fixtures', 'docx', 'Zeichnungsschein_Vorlage.docx')),
        filename: 'sample.docx',
        content_type: Mime[:docx].to_s
      )
      doc
    end

    it 'destroys the existing subscription agreement' do
      allow(investor).to receive(:find_generated_document_by_category) { generated_subscription_agreement }
      expect(generated_subscription_agreement).to receive(:destroy!)
      investor.regenerated_subscription_agreement_document(current_user)
    end

    it 'creates a new generated subscription agreement' do
      new_generated_subscription_agreement = investor.regenerated_subscription_agreement_document(current_user)
      expect(generated_subscription_agreement.id).not_to eq(new_generated_subscription_agreement.id)
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

  describe '#primary_owner' do
    subject { build(:investor, mandate: mandate, primary_owner: contact) }

    let(:mandate) { build(:mandate) }
    let(:primary_owner) { build(:contact_person, :with_mandate, mandate: mandate) }

    context 'is owner of mandate' do
      let(:contact) { primary_owner }

      it 'is valid' do
        expect(subject).to be_valid
      end
    end

    context 'is not owner of mandate' do
      let(:contact) { build(:contact_person) }

      it 'is invalid' do
        expect(subject).to be_invalid
      end
    end
  end

  describe '#primary_contact' do
    subject { build(:investor, mandate: mandate, primary_contact: contact) }

    let(:mandate) { build(:mandate) }
    let(:primary_contact) { build(:contact_person) }
    let(:mandate_member) { build(:mandate_member, mandate: mandate, contact: primary_contact) }

    context 'is member of mandate' do
      let(:contact) { primary_contact }

      it 'is valid' do
        mandate.mandate_members = [mandate_member]
        expect(subject).to be_valid
      end
    end

    context 'is bookkeeper of mandate' do
      let(:contact) { mandate.bookkeeper }

      it 'is valid' do
        mandate.mandate_members = [mandate_member]
        expect(subject).to be_valid
      end
    end

    context 'is not member of mandate' do
      let(:contact) { build(:contact_person) }

      it 'is invalid' do
        expect(subject).to be_invalid
      end
    end
  end

  describe '#secondary_contact' do
    subject { build(:investor, mandate: mandate, secondary_contact: contact) }

    let(:mandate) { build(:mandate) }
    let(:secondary_contact) { build(:contact_person) }
    let(:mandate_member) { build(:mandate_member, mandate: mandate, contact: secondary_contact) }

    context 'is member of mandate' do
      let(:contact) { secondary_contact }

      it 'is valid' do
        mandate.mandate_members = [mandate_member]
        expect(subject).to be_valid
      end
    end

    context 'is primary consultant of mandate' do
      let(:contact) { mandate.primary_consultant }

      it 'is valid' do
        mandate.mandate_members = [mandate_member]
        expect(subject).to be_valid
      end
    end

    context 'is not member of mandate' do
      let(:contact) { build(:contact_person) }

      it 'is invalid' do
        expect(subject).to be_invalid
      end
    end
  end

  describe '#contact_address' do
    subject { build(:investor, mandate: mandate, primary_owner: primary_owner, contact_address: address) }

    let(:mandate) { build(:mandate) }
    let(:primary_owner) { build(:contact_person, :with_mandate, mandate: mandate) }

    context 'is owned by primary owner' do
      let(:address) { build(:address, owner: primary_owner) }

      it 'is valid' do
        expect(subject).to be_valid
      end
    end

    context 'is owned by primary contact' do
      let(:primary_contact) { build(:contact_person, :with_mandate, mandate: mandate) }
      let(:address) { build(:address, owner: primary_contact) }

      it 'is valid' do
        subject.primary_contact = primary_contact
        expect(subject).to be_valid
      end
    end

    context 'is owned by secondary contact' do
      let(:secondary_contact) { build(:contact_person, :with_mandate, mandate: mandate) }
      let(:address) { build(:address, owner: secondary_contact) }

      it 'is valid' do
        subject.secondary_contact = secondary_contact
        expect(subject).to be_valid
      end
    end

    context 'is not owned by primary owner or primary/secondary contact' do
      let(:address) { build(:address) }

      it 'is invalid' do
        expect(subject).to be_invalid
      end
    end
  end

  describe '#legal_address' do
    subject { build(:investor, mandate: mandate, primary_owner: primary_owner, legal_address: address) }

    let(:mandate) { build(:mandate) }
    let(:primary_owner) { build(:contact_person, :with_mandate, mandate: mandate) }
    let(:legal_address) { build(:address, owner: primary_owner) }

    context 'is owned by primary owner' do
      let(:address) { legal_address }

      it 'is valid' do
        expect(subject).to be_valid
      end
    end

    context 'is not owned by primary owner' do
      let(:address) { build(:address) }

      it 'is invalid' do
        expect(subject).to be_invalid
      end
    end
  end

  describe '#contact_email' do
    subject { build(:investor, mandate: mandate, primary_owner: primary_owner, contact_email: email) }

    let(:mandate) { build(:mandate) }
    let(:primary_owner) { build(:contact_person, :with_mandate, mandate: mandate) }
    let(:contact_email) { build(:email, contact: primary_owner) }

    context 'is owned by primary owner' do
      let(:email) { contact_email }

      it 'is valid' do
        expect(subject).to be_valid
      end
    end

    context 'is not owned by primary owner' do
      let(:email) { build(:email) }

      it 'is invalid' do
        expect(subject).to be_invalid
      end
    end
  end

  describe '#contact_phone' do
    subject { build(:investor, mandate: mandate, primary_owner: primary_owner, contact_phone: phone) }

    let(:mandate) { build(:mandate) }
    let(:primary_owner) { build(:contact_person, :with_mandate, mandate: mandate) }
    let(:contact_phone) { build(:phone, contact: primary_owner) }

    context 'is owned by primary owner' do
      let(:phone) { contact_phone }

      it 'is valid' do
        expect(subject).to be_valid
      end
    end

    context 'is not owned by primary owner' do
      let(:phone) { build(:phone) }

      it 'is invalid' do
        expect(subject).to be_invalid
      end
    end
  end
end
