# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scoreable do
  describe '#calculate_score' do
    describe 'for a person' do
      context 'when some rules apply' do
        let!(:subject) { build(:contact_person) }

        it 'scores minimum' do
          # NOTE
          # first_name, last_name and gender are the minimum required fields for a contact
          # hence the lowest score for a contact is the weights for those three 3 fields (not zero)
          subject.calculate_score

          expect(subject.data_integrity_score).to be_within(0.0001).of(0.1626)
        end

        it 'scores correctly when rule: a specific property from the main model is filled' do
          subject.nationality = 'DE'
          subject.calculate_score

          expect(subject.data_integrity_score).to be_within(0.0001).of(0.2168)
        end

        it 'scores correctly when rule: specific properties from a related model are filled' do
          subject.compliance_detail = build(:compliance_detail, contact: subject)
          subject.calculate_score

          expect(subject.data_integrity_score).to be_within(0.0001).of(0.2954)
        end

        it 'scores correctly when rule: a related model has at least one record' do
          subject.activities << build(:activity)
          subject.calculate_score

          expect(subject.data_integrity_score).to be_within(0.0001).of(0.3469)
        end

        it 'scores correctly when rule: a related model is searched for a specific value' do
          subject.documents << create(:document, category: 'kyc')
          subject.save
          subject.calculate_score

          expect(subject.data_integrity_score).to be_within(0.0001).of(0.271)
        end
      end

      context 'when all rules apply' do
        let!(:subject) { build(:contact_person, :with_contact_details, :with_scoreable_data) }

        it 'scores maximum' do
          subject.activities << build(:activity_note)
          subject.documents << build(:document, category: 'kyc')
          subject.compliance_detail = build(:compliance_detail, contact: subject)
          subject.tax_detail = build(:tax_detail, :with_scoreable_data)
          subject.calculate_score

          expect(subject.data_integrity_score).to be_within(0.0001).of(1.0)
        end
      end

      context 'when person is a mandate owner' do
        it 'rescores the mandate when the owner score changes' do
        end
      end
    end
  end
end
