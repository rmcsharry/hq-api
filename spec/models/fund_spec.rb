# frozen_string_literal: true

# == Schema Information
#
# Table name: funds
#
#  id                            :uuid             not null, primary key
#  duration                      :integer
#  duration_extension            :integer
#  aasm_state                    :string           not null
#  commercial_register_number    :string
#  commercial_register_office    :string
#  currency                      :string
#  name                          :string           not null
#  psplus_asset_id               :string
#  region                        :string
#  strategy                      :string
#  comment                       :text
#  capital_management_company_id :uuid
#  legal_address_id              :uuid
#  primary_contact_address_id    :uuid
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  issuing_year                  :integer
#  type                          :string
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
  it { is_expected.to belong_to(:legal_address).optional }
  it { is_expected.to belong_to(:primary_contact_address).optional }
  it { is_expected.to belong_to(:capital_management_company).optional }
  it { is_expected.to have_many(:addresses) }
  it { is_expected.to have_many(:bank_accounts) }
  it { is_expected.to have_many(:documents) }

  describe '#psplus_asset_id' do
    it { is_expected.to respond_to(:psplus_asset_id) }
    it { is_expected.to validate_length_of(:psplus_asset_id).is_at_most(15) }
  end

  describe '#type' do
    it { is_expected.to validate_presence_of(:type) }
  end

  describe '#region' do
    it { is_expected.to enumerize(:region) }
  end

  describe '#strategy' do
    it { is_expected.to validate_presence_of(:strategy) }
  end

  describe '#aasm_state' do
    it { is_expected.to respond_to(:aasm_state) }
    it { is_expected.to respond_to(:state) }
  end

  describe '#name' do
    it { is_expected.to respond_to(:name) }
    it { is_expected.to validate_presence_of(:name) }
  end

  describe '#issuing_year' do
    it { is_expected.to respond_to(:issuing_year) }
    it { is_expected.to validate_presence_of(:issuing_year) }
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

  describe '#to_s' do
    subject { build(:fund, name: 'HQT Merkur Multi IV GmbH & Co. KG') }

    it 'serializes simple record' do
      expect(subject.to_s).to eq('HQT Merkur Multi IV GmbH & Co. KG')
    end
  end
end
