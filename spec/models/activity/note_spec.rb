# frozen_string_literal: true

# == Schema Information
#
# Table name: activities
#
#  created_at  :datetime         not null
#  creator_id  :uuid
#  description :text
#  ended_at    :datetime
#  ews_id      :string
#  id          :uuid             not null, primary key
#  started_at  :datetime
#  title       :string
#  type        :string
#  updated_at  :datetime         not null
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

RSpec.describe Activity::Note, type: :model do
  subject { build(:activity_note) }

  describe '#started_at' do
    context 'with started_at set' do
      let(:date) { 1.day.ago }

      before do
        subject.started_at = date
      end

      it 'uses started_at' do
        expect(subject.valid?).to be true
        expect(subject.started_at).to eq date
      end
    end

    context 'with no started_at set' do
      it 'uses Time.zone.now' do
        expect(subject.valid?).to be true
        expect(subject.started_at).to be_present
      end
    end
  end

  describe '#ended_at' do
    before do
      subject.ended_at = 1.day.ago
    end

    it 'is set to nil' do
      expect(subject.valid?).to be true
      expect(subject.ended_at).to be_nil
    end
  end
end
