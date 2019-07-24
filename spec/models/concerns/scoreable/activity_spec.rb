# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scoreable::Activity, bullet: false do
  describe 'scoreable#calculate_score' do
    describe 'for contact_person' do
      context 'when activitiy changes' do
        # NOTE
        # We create instead of build, to ensure the after_save callback fires, giving the correct starting score
        # instead of the random score from the contact factory
        let!(:subject) { create(:contact_person) }
        let!(:activity_1) { create(:activity_note) }
        let!(:activity_2) { create(:activity_note) }

        it 'scores correctly when initial activity is added' do
          activity_1.contacts << subject

          expect(subject.data_integrity_missing_fields).not_to include('activities')
          expect(subject.data_integrity_missing_fields.length).to eq(23)
          expect(subject.data_integrity_score).to be_within(0.0001).of(0.3469)
        end

        it 'scores correctly when final activity is removed' do
          activity_1.contacts << subject
          activity_1.contacts.destroy(subject)

          expect(subject.data_integrity_missing_fields).to include('activities')
          expect(subject.data_integrity_missing_fields.length).to eq(24)
          expect(subject.data_integrity_score).to be_within(0.0001).of(0.1626)
        end

        it 'scores correctly when final activity itself is destroyed' do
          activity_1.contacts << subject
          activity_1.destroy!

          expect(subject.data_integrity_missing_fields).to include('activities')
          expect(subject.data_integrity_missing_fields.length).to eq(24)
          expect(subject.data_integrity_score).to be_within(0.0001).of(0.1626)
        end

        it 'does not rescore when adding activites after the first one' do
          activity_1.contacts << subject
          activity_1.save!
          stub_const('Contact', double)
          activity_2.contacts << subject

          expect(subject.data_integrity_missing_fields).not_to include('activities')
          expect(subject.data_integrity_missing_fields.length).to eq(23)
          expect(subject.data_integrity_score).to be_within(0.0001).of(0.3469)
        end

        it 'does not rescore when removing activites except one' do
          activity_1.contacts << subject
          activity_1.save!
          activity_2.contacts << subject
          activity_2.save!
          stub_const('Contact', double)
          activity_1.destroy!

          expect(subject.data_integrity_missing_fields).not_to include('activities')
          expect(subject.data_integrity_missing_fields.length).to eq(23)
          expect(subject.data_integrity_score).to be_within(0.0001).of(0.3469)
        end
      end
    end

    describe 'for contact_organization' do
      context 'when activity changes' do
        # NOTE
        # We create instead of build, to ensure the after_save callback fires, giving the correct starting score
        # instead of the random score from the contact factory
        let!(:subject) { create(:contact_organization) }
        let!(:activity_1) { create(:activity_note) }
        let!(:activity_2) { create(:activity_note) }

        it 'scores correctly when initial activity is added' do
          activity_1.contacts << subject

          expect(subject.data_integrity_missing_fields).not_to include('activities')
          expect(subject.data_integrity_missing_fields.length).to eq(20)
          expect(subject.data_integrity_score).to be_within(0.0001).of(0.2547)
        end

        it 'scores correctly when final activity is removed' do
          activity_1.contacts << subject
          activity_1.contacts.destroy(subject)

          expect(subject.data_integrity_missing_fields).to include('activities')
          expect(subject.data_integrity_missing_fields.length).to eq(21)
          expect(subject.data_integrity_score).to be_within(0.0001).of(0.0943)
        end

        it 'scores correctly when final activity itself is destroyed' do
          activity_1.contacts << subject
          activity_1.destroy!

          expect(subject.data_integrity_missing_fields).to include('activities')
          expect(subject.data_integrity_missing_fields.length).to eq(21)
          expect(subject.data_integrity_score).to be_within(0.0001).of(0.0943)
        end

        it 'does not rescore when adding activites after the first one' do
          activity_1.contacts << subject
          activity_1.save!

          expect(subject).not_to receive(:calculate_score)
          activity_2.contacts << subject
        end

        it 'does not rescore when removing activites except one' do
          activity_1.contacts << subject
          activity_1.save!
          activity_2.contacts << subject
          activity_2.save!

          expect(subject).not_to receive(:calculate_score)
          activity_1.destroy!
        end
      end
    end

    describe 'for mandate' do
      context 'when activity changes' do
        # NOTE
        # We create instead of build, to ensure the after_save callback fires, giving the correct starting score
        # instead of the random score from the contact factory
        let!(:subject) { create(:mandate) }
        let!(:activity_1) { create(:activity_note) }
        let!(:activity_2) { create(:activity_note) }

        it 'scores correctly when initial activity is added' do
          activity_1.mandates << subject

          expect(subject.data_integrity_missing_fields).not_to include('activities')
          expect(subject.data_integrity_missing_fields.length).to eq(10)
          expect(subject.data_integrity_partial_score).to be_within(0.0001).of(0.4805)
        end

        it 'scores correctly when final activity is removed' do
          activity_1.mandates << subject
          activity_1.mandates.destroy(subject)

          expect(subject.data_integrity_missing_fields).to include('activities')
          expect(subject.data_integrity_missing_fields.length).to eq(11)
          expect(subject.data_integrity_partial_score).to be_within(0.0001).of(0.2597)
        end

        it 'scores correctly when final activity itself is destroyed' do
          activity_1.mandates << subject
          activity_1.destroy!

          expect(subject.data_integrity_missing_fields).to include('activities')
          expect(subject.data_integrity_missing_fields.length).to eq(11)
          expect(subject.data_integrity_partial_score).to be_within(0.0001).of(0.2597)
        end

        it 'does not rescore when adding activites after the first one' do
          activity_1.mandates << subject
          activity_1.save!

          expect(subject).not_to receive(:calculate_score)
          activity_2.mandates << subject
        end

        it 'does not rescore when removing activites except one' do
          activity_1.mandates << subject
          activity_1.save!
          activity_2.mandates << subject
          activity_2.save!

          expect(subject).not_to receive(:calculate_score)
          activity_1.destroy!
        end
      end
    end
  end
end
