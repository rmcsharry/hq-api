# frozen_string_literal: true

# == Schema Information
#
# Table name: activities
#
#  id          :uuid             not null, primary key
#  type        :string
#  started_at  :datetime
#  ended_at    :datetime
#  title       :string
#  description :text
#  creator_id  :uuid
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  ews_id      :string
#
# Indexes
#
#  index_activities_on_creator_id  (creator_id)
#
# Foreign Keys
#
#  fk_rails_...  (creator_id => users.id)
#

require 'rails_helper'

RSpec.describe Activity, type: :model do
  describe '#mandates' do
    it { is_expected.to have_and_belong_to_many(:mandates) }
  end

  describe '#contacts' do
    it { is_expected.to have_and_belong_to_many(:contacts) }
  end

  describe '#creator' do
    it { is_expected.to belong_to(:creator) }
  end

  describe '#title' do
    it { is_expected.to validate_presence_of(:title) }
  end

  describe '#description' do
    it { is_expected.to validate_presence_of(:description) }
  end

  describe '#ended_at_greater_started_at' do
    subject { build(:activity_call, started_at: started_at, ended_at: ended_at) }
    let(:started_at) { 1.day.ago }

    context 'ended_at before started_at' do
      let(:ended_at) { started_at - 1.hour }

      it 'is invalid' do
        expect(subject).not_to be_valid
        expect(subject.errors.messages[:ended_at]).to include('has to be after started_at')
      end
    end

    context 'ended_at after started_at' do
      let(:ended_at) { started_at + 1.hour }

      it 'is invalid' do
        expect(subject).to be_valid
      end
    end
  end
end
