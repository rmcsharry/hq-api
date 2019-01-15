# frozen_string_literal: true

# == Schema Information
#
# Table name: investors
#
#  id                   :uuid             not null, primary key
#  fund_id              :uuid
#  mandate_id           :uuid
#  legal_address_id     :uuid
#  contact_address_id   :uuid
#  contact_email_id     :uuid
#  contact_phone_id     :uuid
#  bank_account_id      :uuid
#  primary_owner_id     :uuid
#  aasm_state           :string           not null
#  investment_date      :datetime
#  amount_total         :decimal(20, 2)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  primary_contact_id   :uuid
#  secondary_contact_id :uuid
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

  describe '#amount_total' do
    it { is_expected.to respond_to(:amount_total) }
    it { is_expected.to validate_presence_of(:amount_total) }
  end

  describe '#amount_open' do
    it { is_expected.to respond_to(:amount_open) }

    # TODO: Add meaningful specs
  end

  describe '#current_value' do
    it { is_expected.to respond_to(:current_value) }

    # TODO: Add meaningful specs
  end

  describe '#amount_total_distribution' do
    it { is_expected.to respond_to(:amount_total_distribution) }

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
end
