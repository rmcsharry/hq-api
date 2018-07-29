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

RSpec.describe Activity::Note, type: :model do
  subject { build(:activity_note) }

  describe '#started_at' do
    before do
      subject.started_at = 1.day.ago
    end

    it 'is set to nil' do
      expect(subject.valid?).to be true
      expect(subject.started_at).to be_nil
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
