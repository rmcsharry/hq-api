# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scoreable::Activity, bullet: false do
  describe 'scoreable#calculate_score' do
    describe 'for contact_person' do
      context 'when activitiy changes' do
        # NOTE
        # We create instead of build, to ensure the after_save callback fires, giving the correct starting score
        # instead of the random score from the contact factory
        subject { create(:contact_person) }
        let!(:activity_1) { create(:activity_note, contacts: contact_list) }
        let!(:activity_2) { create(:activity_note) }
        let!(:contact_list) { [] }

        before :each do
          activity_1.contacts << subject
        end

        describe 'when initial activity is added' do
          it 'scores correctly' do
            expect(subject.data_integrity_missing_fields).not_to include('activities')
            expect(subject.data_integrity_missing_fields.length).to eq(23)
            expect(subject.data_integrity_score).to be_within(0.0001).of(0.3469)
          end
        end

        describe 'when final activity is removed' do
          before do
            activity_1.contacts.destroy(subject)
          end

          it 'scores correctly' do
            expect(subject.data_integrity_missing_fields).to include('activities')
            expect(subject.data_integrity_missing_fields.length).to eq(24)
            expect(subject.data_integrity_score).to be_within(0.0001).of(0.1626)
          end
        end

        describe 'when final activity itself is destroyed' do
          before do
            activity_1.destroy!
          end

          it 'scores correctly' do
            expect(subject.data_integrity_missing_fields).to include('activities')
            expect(subject.data_integrity_missing_fields.length).to eq(24)
            expect(subject.data_integrity_score).to be_within(0.0001).of(0.1626)
          end
        end

        describe 'when adding activites after the first one' do
          it 'does not rescore' do
            expect(subject).not_to receive(:calculate_score)
            activity_2.contacts << subject
          end
        end

        describe 'when removing activites beyond the first' do
          let!(:activity_2) { create(:activity_note, contacts: [subject]) }

          it 'does not rescore' do
            expect(subject).not_to receive(:calculate_score)
            activity_1.destroy!
          end
        end
      end
    end

    describe 'for contact_organization' do
      context 'when activity changes' do
        # NOTE
        # We create instead of build, to ensure the after_save callback fires, giving the correct starting score
        # instead of the random score from the contact factory
        subject { create(:contact_organization) }
        let!(:activity_1) { create(:activity_note, contacts: contact_list) }
        let!(:activity_2) { create(:activity_note) }
        let!(:contact_list) { [] }

        before :each do
          activity_1.contacts << subject
        end

        describe 'when initial activity is added' do
          it 'scores correctly' do
            expect(subject.data_integrity_missing_fields).not_to include('activities')
            expect(subject.data_integrity_missing_fields.length).to eq(20)
            expect(subject.data_integrity_score).to be_within(0.0001).of(0.2547)
          end
        end

        describe 'when final activity is removed' do
          before do
            activity_1.contacts.destroy(subject)
          end

          it 'scores correctly' do
            expect(subject.data_integrity_missing_fields).to include('activities')
            expect(subject.data_integrity_missing_fields.length).to eq(21)
            expect(subject.data_integrity_score).to be_within(0.0001).of(0.0943)
          end
        end

        describe 'when final activity itself is destroyed' do
          before do
            activity_1.destroy!
          end

          it 'scores correctly' do
            expect(subject.data_integrity_missing_fields).to include('activities')
            expect(subject.data_integrity_missing_fields.length).to eq(21)
            expect(subject.data_integrity_score).to be_within(0.0001).of(0.0943)
          end
        end

        describe 'when adding activites after the first one' do
          it 'does not rescore' do
            expect(subject).not_to receive(:calculate_score)
            activity_2.contacts << subject
          end
        end

        describe 'when removing activites beyond the first' do
          let!(:activity_2) { create(:activity_note, contacts: [subject]) }

          it 'does not rescore' do
            expect(subject).not_to receive(:calculate_score)
            activity_1.destroy!
          end
        end
      end
    end

    describe 'for mandate' do
      context 'when activity changes' do
        # NOTE
        # We create instead of build, to ensure the after_save callback fires, giving the correct starting score
        # instead of the random score from the contact factory
        subject { create(:mandate) }
        let!(:activity_1) { create(:activity_note, mandates: mandate_list) }
        let!(:activity_2) { create(:activity_note) }
        let!(:mandate_list) { [] }

        before :each do
          activity_1.mandates << subject
        end

        describe 'when initial activity is added' do
          it 'scores correctly' do
            expect(subject.data_integrity_missing_fields).not_to include('activities')
            expect(subject.data_integrity_missing_fields.length).to eq(10)
            expect(subject.data_integrity_partial_score).to be_within(0.0001).of(0.4805)
          end
        end

        describe 'when final activity is removed' do
          before do
            activity_1.mandates.destroy(subject)
          end

          it 'scores correctly' do
            expect(subject.data_integrity_missing_fields).to include('activities')
            expect(subject.data_integrity_missing_fields.length).to eq(11)
            expect(subject.data_integrity_partial_score).to be_within(0.0001).of(0.2597)
          end
        end

        describe 'scores correctly when final activity itself is destroyed' do
          before do
            activity_1.destroy!
          end

          it 'scores correctly' do
            expect(subject.data_integrity_missing_fields).to include('activities')
            expect(subject.data_integrity_missing_fields.length).to eq(11)
            expect(subject.data_integrity_partial_score).to be_within(0.0001).of(0.2597)
          end
        end

        describe 'when adding activites after the first one' do
          it 'does not rescore' do
            expect(subject).not_to receive(:calculate_score)
            activity_2.mandates << subject
          end
        end

        describe 'when removing activites' do
          let!(:activity_2) { create(:activity_note, mandates: [subject]) }

          it 'does not rescore' do
            expect(subject).not_to receive(:calculate_score)
            activity_1.destroy!
          end
        end
      end
    end
  end
end
