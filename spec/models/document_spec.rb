# frozen_string_literal: true

# == Schema Information
#
# Table name: documents
#
#  aasm_state  :string           default("created"), not null
#  category    :string           not null
#  created_at  :datetime         not null
#  id          :uuid             not null, primary key
#  name        :string           not null
#  owner_id    :uuid
#  owner_type  :string
#  type        :string
#  updated_at  :datetime         not null
#  uploader_id :uuid             not null
#  valid_from  :date
#  valid_to    :date
#
# Indexes
#
#  index_documents_on_owner_type_and_owner_id  (owner_type,owner_id)
#  index_documents_on_uploader_id              (uploader_id)
#
# Foreign Keys
#
#  fk_rails_...  (uploader_id => users.id)
#

require 'rails_helper'

RSpec.describe Document, type: :model do
  describe '#owner' do
    it { is_expected.to belong_to(:owner) }
  end

  describe '#uploader' do
    it { is_expected.to belong_to(:uploader) }
  end

  describe '#file' do
    it { is_expected.to respond_to(:file) }
  end

  describe '#name' do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe '#category' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to enumerize(:category) }
  end

  describe '#reminders' do
    it { is_expected.to have_many(:reminders) }
  end

  describe '#aasm_state' do
    it { is_expected.to respond_to(:aasm_state) }
    it { is_expected.to respond_to(:state) }
  end

  describe '#archive' do
    let(:document) { create :document }

    it 'transitions state from :created to :archived' do
      document.update! state: 'created'
      document.archive!

      expect(document.state).to eq('archived')
    end
  end

  describe '#unarchive' do
    let(:document) { create :document }

    it 'transitions state from :archived to :created' do
      document.update! state: 'archived'
      document.unarchive!

      expect(document.state).to eq('created')
    end
  end

  describe '#valid_to_greater_or_equal_valid_from' do
    subject { build(:document, valid_from: valid_from, valid_to: valid_to) }
    let(:valid_from) { 5.days.ago }
    let(:valid_to) { Time.zone.today }

    context 'valid_to after valid_from' do
      it 'is valid' do
        expect(subject).to be_valid
      end
    end

    context 'valid_to is not set' do
      let(:valid_to) { nil }

      it 'is valid' do
        expect(subject).to be_valid
      end
    end

    context 'valid_from is not set' do
      let(:valid_from) { nil }

      it 'is valid' do
        expect(subject).to be_valid
      end
    end

    context 'valid_to before valid_from' do
      let(:valid_to) { valid_from - 1.day }

      it 'is invalid' do
        expect(subject).to be_invalid
        expect(subject.errors.messages[:valid_to]).to include("can't be before valid_from")
      end
    end

    context 'valid_to on valid_from' do
      let(:valid_to) { valid_from }

      it 'is valid' do
        expect(subject).to be_valid
      end
    end
  end

  describe 'prevent deletion after 24 hours' do
    context 'not older than 24 hours' do
      subject { create(:document, created_at: 23.hours.ago) }

      it 'can be deleted' do
        expect(subject.destroy!).to be_truthy
      end
    end

    context 'older than 24 hours' do
      subject do
        Timecop.freeze(1.day.ago) do
          create(:document, created_at: 1.day.ago)
        end
      end

      it 'cannot be deleted' do
        expect { subject.destroy! }.to raise_error(ActiveRecord::ReadOnlyRecord)
      end
    end
  end

  describe 'prevent update after 24 hours' do
    context 'not older than 24 hours' do
      subject { create(:document, created_at: 23.hours.ago) }

      it 'can be changed' do
        subject.name = 'New document'
        subject.category = :kyc
        expect(subject.save).to be_truthy
      end
    end

    context 'older than 24 hours' do
      subject do
        Timecop.freeze(1.day.ago) do
          create(:document, created_at: 1.day.ago, state: 'created')
        end
      end

      it 'cannot update name or category' do
        subject.name = 'New document'
        subject.category = :kyc
        expect { subject.save }.to raise_error(ActiveRecord::ReadOnlyRecord)
      end

      it 'can still update aasm_state' do
        subject.state = 'archived'
        subject.save
        expect(subject.reload.state).to eq('archived')
      end
    end
  end
end
