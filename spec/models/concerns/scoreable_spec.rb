# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scoreable, bullet: false do
  describe '#calculate_score' do
    describe 'for contact_person' do
      context 'when some rules apply' do
        subject { build(:contact_person) }

        it 'is correct when minimum rules pass' do
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
      end

      context 'when all rules apply' do
        subject { build(:contact_person, :with_contact_details, :with_scoreable_data) }

        before do
          subject.activities << build(:activity_note)
          subject.documents << build(:document, category: 'kyc')
          subject.compliance_detail = build(:compliance_detail, contact: subject)
          subject.tax_detail = build(:tax_detail, :with_scoreable_person_data)
          subject.save!
          subject.calculate_score
        end

        it 'scores maximum' do
          expect(subject.data_integrity_missing_fields.length).to eq(0)
          expect(subject.data_integrity_score).to be_within(0.0001).of(1.0)
        end
      end
    end

    describe 'for contact_organization' do
      context 'when some rules apply' do
        subject { build(:contact_organization) }

        it 'is correct when minimum rules pass' do
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
      end

      context 'when all rules apply' do
        subject do
          create(
            :contact_organization,
            :with_contact_details,
            :with_scoreable_data,
            :with_scoreable_relationships
          )
        end

        before do
          subject.activities << build(:activity_note)
          subject.documents << build(:document, category: 'kyc')
          subject.compliance_detail = build(:compliance_detail, contact: subject)
          subject.tax_detail = build(:tax_detail, :with_scoreable_organization_data)
          subject.calculate_score
        end

        it 'scores maximum' do
          expect(subject.data_integrity_score).to be_within(0.0001).of(1.0)
          expect(subject.data_integrity_missing_fields.length).to eq(0)
        end
      end
    end

    describe 'for mandate' do
      context 'when some rules apply' do
        subject { build(:mandate) }

        it 'is correct when minimum rules pass' do
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
      end

      context 'when all rules apply' do
        let(:primary_owner) { build(:contact_person) }
        subject do
          create(
            :mandate,
            :with_bank_account,
            :with_scoreable_data,
            :with_owner,
            owner: primary_owner,
            primary_owner: primary_owner
          )
        end

        before do
          subject.documents << create(:document, category: 'contract_hq')
          subject.activities << create(:activity_note)
          subject.mandate_members <<
            [
              create(:mandate_member, mandate: subject, member_type: :primary_consultant),
              create(:mandate_member, mandate: subject, member_type: :secondary_consultant),
              create(:mandate_member, mandate: subject, member_type: :assistant),
              create(:mandate_member, mandate: subject, member_type: :bookkeeper)
            ]
          subject.reload
          subject.calculate_score
        end

        it 'scores maximum' do
          expect(subject.data_integrity_partial_score).to be_within(0.0001).of(1.0)
          expect(subject.data_integrity_missing_fields.length).to eq(0)
        end
      end

      context 'when the mandate owner rule is factored in' do
        subject { create(:mandate, :with_bank_account, :with_scoreable_data) }
        let!(:contact) { create(:contact_person, :with_contact_details, :with_scoreable_data) }

        before do
          subject.activities << build(:activity_note)
          subject.documents << build(:document, category: 'contract_hq')
          contact.calculate_score
        end

        it 'is correct (both scores) when no owner' do
          expect(subject.data_integrity_missing_fields).to include('owner')
          expect(subject.data_integrity_missing_fields.length).to eq(1)
          expect(subject.data_integrity_partial_score).to be_within(0.0001).of(0.9351)
          expect(subject.data_integrity_score).to be_within(0.0001).of(0.4676)
        end

        context 'when 1 owner added who is not scored max' do
          before do
            contact.save!
            # now the contact score is persisted, add the contact as the owner, and calculate the mandate score
            subject.mandate_members << create(:mandate_member, mandate: subject, contact: contact)
            subject.save!
            subject.reload
            subject.calculate_score
          end

          it 'scores max partial score but lower overall score' do
            expect(subject.data_integrity_missing_fields).not_to include('owner')
            expect(subject.data_integrity_missing_fields.length).to eq(0)
            expect(subject.data_integrity_partial_score).to be_within(0.0001).of(1.0)
            expect(subject.data_integrity_score).to be_within(0.0001).of(0.7439)
          end
        end

        context 'when 1 owner added who is scored max' do
          it 'is correct (max for both scores)' do
            contact.activities << build(:activity_note)
            contact.documents << build(:document, category: 'kyc')
            contact.compliance_detail = build(:compliance_detail, contact: contact)
            contact.tax_detail = build(:tax_detail, :with_scoreable_person_data)
            contact.calculate_score
            contact.save!
            # ensure the contact is at max before running the actual test
            expect(contact.data_integrity_missing_fields.length).to eq(0)
            expect(contact.data_integrity_score).to be_within(0.0001).of(1.0)

            # now max the mandate score, including the contact as owner
            subject.activities << create(:activity_note)
            subject.documents << create(:document, category: 'contract_hq')
            subject.mandate_members << create(:mandate_member, mandate: subject, contact: contact)
            subject.save!
            subject.reload
            subject.calculate_score

            expect(subject.data_integrity_missing_fields.length).to eq(0)
            expect(subject.data_integrity_partial_score).to be_within(0.0001).of(1.0)
            expect(subject.data_integrity_score).to be_within(0.0001).of(1.0)
          end
        end

        it 'is correct (both scores) when owner is removed' do
          contact.calculate_score
          contact.save!
          subject.mandate_members << create(:mandate_member, mandate: subject, contact: contact)
          subject.save!
          subject.reload
          subject.calculate_score

          expect(subject.data_integrity_missing_fields).not_to include('owner')
          expect(subject.data_integrity_missing_fields.length).to eq(2)
          expect(subject.data_integrity_partial_score).to be_within(0.0001).of(0.5844)
          expect(subject.data_integrity_score).to be_within(0.0001).of(0.5361) # (0.5844 + 0.4878) / 2

          subject.mandate_members.find_by(member_type: :owner).destroy # <- this action is the focus of this test
          subject.save!
          subject.reload
          subject.calculate_score

          expect(subject.data_integrity_missing_fields).to include('owner')
          expect(subject.data_integrity_missing_fields.length).to eq(3)
          expect(subject.data_integrity_partial_score).to be_within(0.0001).of(0.5195)
          expect(subject.data_integrity_score).to be_within(0.0001).of(0.2598) # (0.5195 + 0.0) / 2
        end
      end
    end
  end
end
