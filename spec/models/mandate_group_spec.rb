# == Schema Information
#
# Table name: mandate_groups
#
#  id         :uuid             not null, primary key
#  name       :string
#  group_type :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe MandateGroup, type: :model do
  describe '#mandates' do
    it { is_expected.to have_and_belong_to_many(:mandates) }
  end

  describe '#user_groups' do
    it { is_expected.to have_and_belong_to_many(:user_groups) }
  end

  describe '#name' do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe '#group_type' do
    it { is_expected.to validate_presence_of(:group_type) }
    it { is_expected.to enumerize(:group_type) }
  end
end
