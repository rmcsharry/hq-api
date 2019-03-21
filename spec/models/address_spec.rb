# frozen_string_literal: true

# == Schema Information
#
# Table name: addresses
#
#  id                :uuid             not null, primary key
#  owner_id          :uuid             not null
#  postal_code       :string
#  city              :string
#  country           :string
#  addition          :string
#  state             :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  category          :string
#  street_and_number :string
#  owner_type        :string           not null
#
# Indexes
#
#  index_addresses_on_owner_type_and_owner_id  (owner_type,owner_id)
#

require 'rails_helper'

RSpec.describe Address, type: :model do
  it { is_expected.to validate_presence_of(:street_and_number) }
  it { is_expected.to validate_presence_of(:postal_code) }
  it { is_expected.to validate_presence_of(:city) }
  it { is_expected.to respond_to(:state) }

  describe '#owner' do
    it { is_expected.to belong_to(:owner).required }
  end

  describe '#category' do
    it { is_expected.to validate_presence_of(:category) }
    it { is_expected.to enumerize(:category) }
  end

  describe '#country' do
    it { is_expected.to validate_presence_of(:country) }
    it { is_expected.to enumerize(:country) }
  end

  describe '#to_s' do
    it 'serializes simple record' do
      address = create(
        :address,
        postal_code: 10_999,
        city: 'Berlin',
        country: 'DE',
        addition: nil,
        street_and_number: 'Oranienstraße 185'
      )

      expect(address.to_s).to eq('Oranienstraße 185, 10999, Berlin, DE')
    end

    it 'serializes record with addition' do
      address = create(
        :address,
        postal_code: 10_999,
        city: 'Berlin',
        country: 'DE',
        addition: 'Aufgang 3',
        street_and_number: 'Oranienstraße 185'
      )

      expect(address.to_s).to eq('Oranienstraße 185, Aufgang 3, 10999, Berlin, DE')
    end
  end

  context 'addresses marked as legal' do
    let!(:address) { create(:address, legal_address: true, owner: owner) }
    let(:owner) { create(:contact_person) }

    it 'creates the legal address for the owner' do
      expect(owner.legal_address).to be(address)
    end

    it 'does not remove the legal address implicitly for the owner' do
      address.update(legal_address: nil)
      expect(owner.legal_address).not_to be_nil
    end

    it 'removes the legal address for the owner' do
      address.update(legal_address: false)
      expect(owner.legal_address).to be_nil
    end
  end

  context 'addresses marked as primary contact' do
    let!(:address) { create(:address, primary_contact_address: true, owner: owner) }
    let(:owner) { create(:contact_person) }

    it 'creates the primary contact address for the owner' do
      expect(owner.primary_contact_address).to be(address)
    end

    it 'does not remove the primary contact address implicitly for the owner' do
      address.update(primary_contact_address: nil)
      expect(owner.primary_contact_address).not_to be_nil
    end

    it 'removes the primary contact address for the owner' do
      address.update(primary_contact_address: false)
      expect(owner.primary_contact_address).to be_nil
    end
  end
end
