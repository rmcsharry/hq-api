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
end
