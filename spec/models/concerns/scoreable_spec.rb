# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scoreable, bullet: false do
  describe '#calculate_score' do
    describe 'for contact_person' do
      context 'when some rules apply' do
        let!(:subject) { build(:contact_person) }

        it 'scores minimum' do
          # NOTE
          # first_name, last_name and gender are the minimum required fields for a contact
          # hence the lowest score is the weights for those 3 fields (not zero)
          subject.calculate_score

          expect(subject.data_integrity_missing_fields).not_to include('first_name', 'last_name', 'date_of_birth')
          expect(subject.data_integrity_missing_fields.length).to eq(24)
          expect(subject.data_integrity_score).to be_within(0.0001).of(0.1626)
        end

        it 'is correct when rule: a specific property from the main model is filled' do
          subject.nationality = 'DE'
          subject.calculate_score

          expect(subject.data_integrity_missing_fields).not_to include('nationality')
          expect(subject.data_integrity_missing_fields.length).to eq(23)
          expect(subject.data_integrity_score).to be_within(0.0001).of(0.2168)
        end

        it 'is correct when rule: specific properties from a related model are filled' do
          subject.compliance_detail = build(:compliance_detail, contact: subject)
          subject.calculate_score

          expect(subject.data_integrity_missing_fields).not_to include(
            'kagb_classification',
            'occupation_role',
            'occupation_title',
            'politically_exposed',
            'retirement_age',
            'wphg_classification'
          )
          expect(subject.data_integrity_missing_fields.length).to eq(18)
          expect(subject.data_integrity_score).to be_within(0.0001).of(0.3062)
        end

        it 'is correct when rule: a related model has at least one record' do
          subject.activities << build(:activity)
          subject.calculate_score

          expect(subject.data_integrity_missing_fields).not_to include('activities')
          expect(subject.data_integrity_missing_fields.length).to eq(23)
          expect(subject.data_integrity_score).to be_within(0.0001).of(0.3469)
        end

        it 'is correct when rule: a related model is searched for a specific value' do
          subject.documents << build(:document, category: 'kyc')
          subject.save # needed to ensure the document type is found by the algorithm
          subject.calculate_score

          expect(subject.data_integrity_missing_fields).not_to include('kyc')
          expect(subject.data_integrity_missing_fields.length).to eq(23)
          expect(subject.data_integrity_score).to be_within(0.0001).of(0.271)
        end
      end

      context 'when all rules apply' do
        let!(:subject) { build(:contact_person, :with_contact_details, :with_scoreable_data) }

        it 'scores maximum' do
          subject.activities << build(:activity_note)
          subject.documents << build(:document, category: 'kyc')
          subject.compliance_detail = build(:compliance_detail, contact: subject)
          subject.tax_detail = build(:tax_detail, :with_scoreable_person_data)
          subject.calculate_score
          puts subject.data_integrity_missing_fields

          expect(subject.data_integrity_missing_fields.length).to eq(0)
          expect(subject.data_integrity_score).to be_within(0.0001).of(1.0)
        end
      end

      context 'when related model changes' do
        let!(:subject) { build(:contact_person) }
        let!(:activity) { build(:activity_note) }

        it 'scores correctly when initial activity is added' do
          subject.calculate_score
          activity.contacts << subject
          activity.save
          subject.reload

          expect(subject.data_integrity_missing_fields).not_to include('activities')
          expect(subject.data_integrity_missing_fields.length).to eq(23)
          expect(subject.data_integrity_score).to be_within(0.0001).of(0.3469)
        end

        it 'scores correctly when final activity is removed' do
          subject.calculate_score
          activity.contacts << subject
          activity.save

          activity.destroy
          activity.contacts.destroy(subject)
          subject.reload

          expect(subject.data_integrity_missing_fields).to include('activities')
          expect(subject.data_integrity_missing_fields.length).to eq(24)
          expect(subject.data_integrity_score).to be_within(0.0001).of(0.1626)
        end
      end

      context 'when person is a mandate owner' do
        it 'rescores the mandate when the owner score changes' do
        end
      end
    end

    describe 'for contact_organization' do
      context 'when some rules apply' do
        let!(:subject) { build(:contact_organization) }

        it 'scores minimum' do
          # NOTE
          # name and type are the minimum required fields for an organization
          # hence the lowest score is the weights for those 2 fields (not zero)
          subject.calculate_score

          expect(subject.data_integrity_missing_fields).not_to include('organization_name', 'organization_type')
          expect(subject.data_integrity_missing_fields.length).to eq(21)
          expect(subject.data_integrity_score).to be_within(0.0001).of(0.0943)
        end

        it 'is correct when rule: a specific property from the main model is filled' do
          subject.organization_category = Faker::Company.type
          subject.calculate_score

          expect(subject.data_integrity_missing_fields).not_to include('organization_category')
          expect(subject.data_integrity_missing_fields.length).to eq(20)
          expect(subject.data_integrity_score).to be_within(0.0001).of(0.1415)
        end

        it 'is correct when rule: specific properties from a related model are filled' do
          subject.compliance_detail = build(:compliance_detail, contact: subject)
          subject.calculate_score

          expect(subject.data_integrity_missing_fields).not_to include('kagb_classification', 'wphg_classification')
          expect(subject.data_integrity_missing_fields.length).to eq(19)
          expect(subject.data_integrity_score).to be_within(0.0001).of(0.1887)
        end

        it 'is correct when rule: a related model has at least one record' do
          subject.activities << build(:activity)
          subject.calculate_score

          expect(subject.data_integrity_missing_fields).not_to include('activities')
          expect(subject.data_integrity_missing_fields.length).to eq(20)
          expect(subject.data_integrity_score).to be_within(0.0001).of(0.2547)
        end

        it 'is correct when rule: a related model is searched for a specific value' do
          subject.documents << build(:document, category: 'kyc')
          subject.save # needed to ensure the document type is found by the algorithm
          subject.calculate_score

          expect(subject.data_integrity_missing_fields).not_to include('kyc')
          expect(subject.data_integrity_missing_fields.length).to eq(20)
          expect(subject.data_integrity_score).to be_within(0.0001).of(0.1887)
        end
      end

      context 'when all rules apply' do
        let!(:subject) do
          create(
            :contact_organization,
            :with_contact_details,
            :with_scoreable_data,
            :with_scoreable_relationships
          )
        end

        it 'scores maximum' do
          subject.activities << build(:activity_note)
          subject.documents << build(:document, category: 'kyc')
          subject.compliance_detail = build(:compliance_detail, contact: subject)
          subject.tax_detail = build(:tax_detail, :with_scoreable_organization_data)
          subject.calculate_score

          expect(subject.data_integrity_score).to be_within(0.0001).of(1.0)
          expect(subject.data_integrity_missing_fields.length).to eq(0)
        end
      end

      context 'when organization is a mandate owner' do
        it 'rescores the mandate when the owner score changes' do
        end
      end
    end
  end
end
