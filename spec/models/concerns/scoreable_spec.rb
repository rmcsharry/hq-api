# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scoreable, bullet: false do
  describe '#calculate_score' do
    describe 'for contact_person' do
      context 'when some rules apply' do
        let!(:subject) { build(:contact_person) }

        it 'scores minimum' do
          # NOTE
          # we check the minimum required fields for a contact
          # hence the lowest score is the weights for those fields (not zero)
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

          expect(subject.data_integrity_missing_fields.length).to eq(0)
          expect(subject.data_integrity_score).to be_within(0.0001).of(1.0)
        end
      end

      context 'when related model changes' do
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
          # we check the minimum required fields for an organization
          # hence the lowest score is the weights for those fields (not zero)
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

      context 'when related model changes' do
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
          stub_const('Contact', double)
          activity_2.contacts << subject

          expect(subject.data_integrity_missing_fields).not_to include('activities')
          expect(subject.data_integrity_missing_fields.length).to eq(20)
          expect(subject.data_integrity_score).to be_within(0.0001).of(0.2547)
        end

        it 'does not rescore when removing activites except one' do
          activity_1.contacts << subject
          activity_1.save!
          activity_2.contacts << subject
          activity_2.save!
          stub_const('Contact', double)
          activity_1.destroy!

          expect(subject.data_integrity_missing_fields).not_to include('activities')
          expect(subject.data_integrity_missing_fields.length).to eq(20)
          expect(subject.data_integrity_score).to be_within(0.0001).of(0.2547)
        end
      end

      context 'when organization is a mandate owner' do
        it 'rescores the mandate when the owner score changes' do
        end
      end
    end

    describe 'for mandate' do
      context 'when some rules apply' do
        let!(:subject) { build(:mandate) }

        it 'scores minimum' do
          # NOTE
          # we check the minimum required fields for a mandate
          # hence the lowest score is the weights for those fields (not zero)
          subject.calculate_score

          expect(subject.data_integrity_missing_fields).not_to include(
            'category', 'state', 'primary_consultant', 'secondary_consultant'
          )
          expect(subject.data_integrity_missing_fields.length).to eq(11)
          expect(subject.data_integrity_partial_score).to be_within(0.0001).of(0.2597)
        end

        it 'is correct when rule: a specific property from the main model is filled' do
          subject.psplus_id = '1234567890'
          subject.calculate_score

          expect(subject.data_integrity_missing_fields).not_to include('psplus_id')
          expect(subject.data_integrity_missing_fields.length).to eq(10)
          expect(subject.data_integrity_partial_score).to be_within(0.0001).of(0.2727)
        end

        it 'is correct when rule: a related model has at least one record' do
          subject.activities << build(:activity_note)
          subject.calculate_score

          expect(subject.data_integrity_missing_fields).not_to include('activities')
          expect(subject.data_integrity_missing_fields.length).to eq(10)
          expect(subject.data_integrity_partial_score).to be_within(0.0001).of(0.4805)
        end

        it 'is correct when rule: a related model is searched for a specific value' do
          subject.documents << build(:document, category: 'contract_hq')
          subject.calculate_score

          expect(subject.data_integrity_missing_fields).not_to include('contract_hq')
          expect(subject.data_integrity_missing_fields.length).to eq(10)
          expect(subject.data_integrity_partial_score).to be_within(0.0001).of(0.4545)
        end
      end

      context 'when the mandate owner rule is factored in' do
        let!(:subject) { create(:mandate, :with_bank_account, :with_scoreable_data) }
        let!(:contact) { create(:contact_person, :with_contact_details, :with_scoreable_data) }

        it 'scores almost maximum with no owner' do
          subject.activities << build(:activity_note)
          subject.documents << build(:document, category: 'contract_hq')
          subject.calculate_score

          expect(subject.data_integrity_missing_fields).to include('owner')
          expect(subject.data_integrity_missing_fields.length).to eq(1)
          expect(subject.data_integrity_score).to be_within(0.0001).of(0.4676)
          expect(subject.data_integrity_partial_score).to be_within(0.0001).of(0.9351)
        end

        it 'scores maximum partial score but less than 100% overall (with 1 owner not scored max)' do
          subject.activities << build(:activity_note)
          subject.documents << build(:document, category: 'contract_hq')
          subject.mandate_members << create(:mandate_member, mandate: subject, contact: contact)
          subject.reload
          subject.calculate_score

          expect(subject.data_integrity_missing_fields).not_to include('owner')
          expect(subject.data_integrity_missing_fields.length).to eq(0)
          expect(subject.data_integrity_score).to be_within(0.0001).of(0.7439)
          expect(subject.data_integrity_partial_score).to be_within(0.0001).of(1.0)
        end

        it 'scores maximum scores (with 1 owner scored max)' do
          contact.activities << build(:activity_note)
          contact.documents << build(:document, category: 'kyc')
          contact.compliance_detail = build(:compliance_detail, contact: contact)
          contact.tax_detail = build(:tax_detail, :with_scoreable_person_data)
          contact.reload
          contact.calculate_score
          contact.save!
          # ensure the contact is at max before doing the actual test
          expect(contact.data_integrity_missing_fields.length).to eq(0)
          expect(contact.data_integrity_score).to be_within(0.0001).of(1.0)

          subject.activities << create(:activity_note)
          subject.documents << create(:document, category: 'contract_hq')
          subject.mandate_members << create(:mandate_member, mandate: subject, contact: contact)
          subject.reload
          subject.calculate_score
          subject.save!

          expect(subject.data_integrity_missing_fields.length).to eq(0)
          expect(subject.data_integrity_score).to be_within(0.0001).of(1.0)
          expect(subject.data_integrity_partial_score).to be_within(0.0001).of(1.0)
        end
      end

      context 'when related model changes' do
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
  end
end
