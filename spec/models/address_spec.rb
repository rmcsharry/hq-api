# frozen_string_literal: true

# == Schema Information
#
# Table name: addresses
#
#  id                :uuid             not null, primary key
#  contact_id        :uuid
#  postal_code       :string
#  city              :string
#  country           :string
#  addition          :string
#  state             :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  category          :string
#  street_and_number :string
#

require 'rails_helper'

RSpec.describe Address, type: :model do
  it { is_expected.to validate_presence_of(:street_and_number) }
  it { is_expected.to validate_presence_of(:postal_code) }
  it { is_expected.to validate_presence_of(:city) }
  it { is_expected.to respond_to(:state) }

  describe '#contact' do
    it { is_expected.to belong_to(:contact).required }
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
end
