# frozen_string_literal: true

# == Schema Information
#
# Table name: mandate_members
#
#  contact_id  :uuid
#  created_at  :datetime         not null
#  end_date    :date
#  id          :uuid             not null, primary key
#  mandate_id  :uuid
#  member_type :string
#  start_date  :date
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_mandate_members_on_contact_id  (contact_id)
#  index_mandate_members_on_mandate_id  (mandate_id)
#
# Foreign Keys
#
#  fk_rails_...  (contact_id => contacts.id)
#  fk_rails_...  (mandate_id => mandates.id)
#

require 'rails_helper'

RSpec.describe MandateMember, type: :model do
  describe '#member_type' do
    it { is_expected.to validate_presence_of(:member_type) }
    it { is_expected.to enumerize(:member_type) }
  end

  describe '#mandate' do
    it { is_expected.to belong_to(:mandate).required }
  end

  describe '#contact' do
    it { is_expected.to belong_to(:contact).required }
  end

  describe '#end_date_greater_or_equal_start_date' do
    subject { build(:mandate_member, start_date: start_date, end_date: end_date) }
    let(:start_date) { 5.days.ago }
    let(:end_date) { Time.zone.today }

    context 'end_date after start_date' do
      it 'is valid' do
        expect(subject).to be_valid
      end
    end

    context 'end_date is not set' do
      let(:end_date) { nil }

      it 'is valid' do
        expect(subject).to be_valid
      end
    end

    context 'start_date is not set' do
      let(:start_date) { nil }

      it 'is valid' do
        expect(subject).to be_valid
      end
    end

    context 'end_date before start_date' do
      let(:end_date) { start_date - 1.day }

      it 'is invalid' do
        expect(subject).to be_invalid
        expect(subject.errors.messages[:end_date]).to include("can't be before start_date")
      end
    end

    context 'end_date on start_date' do
      let(:end_date) { start_date }

      it 'is valid' do
        expect(subject).to be_valid
      end
    end
  end

  describe '#mandate_contact_member_type_unique' do
    subject { build(:mandate_member) }
    it 'is_unique' do
      expect(subject).to(
        validate_uniqueness_of(:contact_id).scoped_to(%i[mandate_id member_type])
                                           .with_message('should occur only once per mandate and member type')
                                           .case_insensitive
      )
    end
  end
end
