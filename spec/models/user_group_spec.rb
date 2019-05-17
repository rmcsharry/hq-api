# frozen_string_literal: true

# == Schema Information
#
# Table name: user_groups
#
#  comment    :text
#  created_at :datetime         not null
#  id         :uuid             not null, primary key
#  name       :string
#  roles      :string           default([]), is an Array
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe UserGroup, type: :model do
  describe '#users' do
    it { is_expected.to have_and_belong_to_many(:users) }
  end

  describe '#mandate_groups' do
    it { is_expected.to have_and_belong_to_many(:mandate_groups) }
  end

  describe '#name' do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe '#comment' do
    it { is_expected.to respond_to(:comment) }
  end

  describe '#user_group_count' do
    subject { create(:user_group) }
    let!(:users) { create_list(:user, 3, user_groups: [subject]) }

    it 'counts 3 user' do
      expect(UserGroup.with_user_count.where(id: subject.id).first.user_count).to eq 3
    end
  end

  describe '#roles' do
    let(:user_group) { create(:user_group) }

    describe 'available roles' do
      UserGroup::AVAILABLE_ROLES.each do |valid_role|
        it "accepts '#{valid_role}'" do
          user_group.roles = [valid_role]
          expect(user_group.valid?).to be(true)
        end
      end
    end

    describe 'unknown roles' do
      it "forbids 'unknown'" do
        user_group.roles = [:unknown]
        expect(user_group.valid?).to be(false)
      end
    end
  end
end
