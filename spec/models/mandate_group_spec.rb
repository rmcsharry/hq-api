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

    describe 'with loaded mandate_groups_mandate relation' do
      it 'counts 3 mandates' do
        ActiveRecord::Base.connection.query_cache.clear
        expect(subject.mandate_groups_mandates.loaded?).to be false
        expect(MandateGroup.find(subject.id).mandate_count).to eq 3
      end
    end

    describe 'without loaded mandate_groups_mandate relation' do
      it 'counts 3 mandates' do
        mandate_group = MandateGroup.includes(:mandate_groups_mandates).where(id: subject.id).first
        expect(mandate_group.mandate_groups_mandates.loaded?).to be true
        expect(mandate_group.mandate_count).to eq 3
      end
    end
  end
end
