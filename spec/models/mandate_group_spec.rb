# frozen_string_literal: true

# == Schema Information
#
# Table name: mandate_groups
#
#  id         :uuid             not null, primary key
#  name       :string
#  group_type :string
#  comment    :text
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

  describe '#families' do
    let!(:family) { create(:mandate_group, group_type: 'family') }
    let!(:organization) { create(:mandate_group, group_type: 'organization') }
    it 'finds all families' do
      expect(MandateGroup.families).to eq [family]
    end
  end

  describe '#organizations' do
    let!(:family) { create(:mandate_group, group_type: 'family') }
    let!(:organization) { create(:mandate_group, group_type: 'organization') }
    it 'finds all organizations' do
      expect(MandateGroup.organizations).to eq [organization]
    end
  end

  describe '#mandate_count' do
    subject { create(:mandate_group) }
    let!(:mandates) { create_list(:mandate, 3, mandate_groups: [subject]) }

    it 'counts 3 mandates' do
      expect(MandateGroup.with_mandate_count.where(id: subject.id).first.mandate_count).to eq 3
    end
  end
end
