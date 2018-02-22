# == Schema Information
#
# Table name: mandates
#
#  id                      :uuid             not null, primary key
#  aasm_state              :string
#  category                :string
#  comment                 :text
#  valid_from              :date
#  valid_to                :date
#  datev_creditor_id       :string
#  datev_debitor_id        :string
#  psplus_id               :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  primary_consultant_id   :uuid
#  secondary_consultant_id :uuid
#  assistant_id            :uuid
#  bookkeeper_id           :uuid
#
# Indexes
#
#  index_mandates_on_assistant_id             (assistant_id)
#  index_mandates_on_bookkeeper_id            (bookkeeper_id)
#  index_mandates_on_primary_consultant_id    (primary_consultant_id)
#  index_mandates_on_secondary_consultant_id  (secondary_consultant_id)
#
# Foreign Keys
#
#  fk_rails_...  (assistant_id => contacts.id)
#  fk_rails_...  (bookkeeper_id => contacts.id)
#  fk_rails_...  (primary_consultant_id => contacts.id)
#  fk_rails_...  (secondary_consultant_id => contacts.id)
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
end
