# frozen_string_literal: true

# == Schema Information
#
# Table name: bank_accounts
#
#  id                  :uuid             not null, primary key
#  account_type        :string
#  owner               :string
#  bank_account_number :string
#  bank_routing_number :string
#  iban                :string
#  bic                 :string
#  currency            :string
#  mandate_id          :uuid
#  bank_id             :uuid
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_bank_accounts_on_bank_id     (bank_id)
#  index_bank_accounts_on_mandate_id  (mandate_id)
#
# Foreign Keys
#
#  fk_rails_...  (bank_id => contacts.id)
#  fk_rails_...  (mandate_id => mandates.id)
#

require 'rails_helper'

RSpec.describe BankAccount, type: :model do
  it { is_expected.to validate_presence_of(:owner) }

  describe '#mandate' do
    it { is_expected.to belong_to(:mandate).required }
  end

  describe '#bank' do
    it { is_expected.to belong_to(:bank).required }
  end

  describe '#curency' do
    it { is_expected.to validate_presence_of(:currency) }
    it { is_expected.to enumerize(:currency) }
  end

  describe '#account_type' do
    it { is_expected.to validate_presence_of(:account_type) }
    it { is_expected.to enumerize(:account_type) }
  end

  describe '#bank information' do
    subject do
      build(
        :bank_account,
        iban: iban,
        bic: bic,
        bank_account_number: bank_account_number,
        bank_routing_number: bank_routing_number,
        bank: bank
      )
    end

    let(:iban) { nil }
    let(:bic) { nil }
    let(:bank_account_number) { nil }
    let(:bank_routing_number) { nil }
    let(:bank) { build(:contact_organization, organization_name: bank_name) }
    let(:bank_name) { 'Deutsche Bank' }

    context 'iban and bic present' do
      let(:iban) { 'DE21301204000000015228' }
      let(:bic) { Faker::Bank.swift_bic }
      it { is_expected.to be_valid }
    end

    context 'iban and bic with spaces' do
      let(:iban) { 'de21 301 204 0 00 00001 5228' }
      let(:bic) { 'DEU TDE bbxxx' }
      it 'are formatted' do
        subject.valid?
        expect(subject.iban).to eq 'DE21301204000000015228'
        expect(subject.bic).to eq 'DEUTDEBBXXX'
      end
    end

    context 'iban present but no bic' do
      let(:iban) { 'DE21301204000000015228' }
      it { is_expected.to_not be_valid }
    end

    context 'bank_account_number and bank_routing_number present' do
      let(:bank_account_number) { '1234567890' }
      let(:bank_routing_number) { '09876543' }
      it { is_expected.to be_valid }
    end

    context 'bank_account_number present but no bank_routing_number' do
      let(:bank_account_number) { '1234567890' }
      it { is_expected.to_not be_valid }
    end

    context 'neither iban nor bank_account_number present' do
      it { is_expected.to_not be_valid }
    end

    context 'iban and bank_account_number present' do
      let(:iban) { 'DE21301204000000015228' }
      let(:bic) { Faker::Bank.swift_bic }
      let(:bank_account_number) { '1234567890' }
      let(:bank_routing_number) { '09876543' }
      it { is_expected.to_not be_valid }
    end

    context 'with bank name present' do
      it "returns the Bank's name" do
        expect(subject.bank_name).to eq('Deutsche Bank')
      end
    end

    context 'without bank name present' do
      let(:bank_name) { nil }
      it 'returns nil' do
        expect(subject.bank_name).to be_nil
      end
    end

    context 'without bank present' do
      let(:bank) { nil }
      it 'returns nil' do
        expect(subject.bank_name).to be_nil
      end
    end
  end
end
