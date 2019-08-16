# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scoreable::DetailBase, bullet: false do
  describe '#rescore_contact (for ComplianceDetail)' do
    describe 'for contact_person' do
      subject { build(:contact_person) }
      let!(:compliance_detail) { build(:compliance_detail, contact: subject) }

      context 'when rule: specific properties from a related model are filled' do
        before do
          subject.compliance_detail = compliance_detail
          compliance_detail.rescore_contact
        end

        it 'scores correctly' do
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
      end
    end
  end

  describe 'for contact_organization' do
    subject { build(:contact_organization) }
    let!(:compliance_detail) { build(:compliance_detail, contact: subject) }

    context 'when rule: specific properties from a related model are filled' do
      before do
        subject.compliance_detail = compliance_detail
        compliance_detail.rescore_contact
      end

      it 'scores correctly' do
        expect(subject.data_integrity_missing_fields).not_to include('kagb_classification', 'wphg_classification')
        expect(subject.data_integrity_missing_fields.length).to eq(19)
        expect(subject.data_integrity_score).to be_within(0.0001).of(0.1887)
      end
    end
  end

  describe '#rescore_contact (for TaxDetail)' do
    describe 'for contact_person' do
      subject { build(:contact_person) }
      let!(:tax_detail) { build(:tax_detail, :with_scoreable_person_data, contact: subject) }

      context 'when rule: specific properties from a related model are filled' do
        before do
          subject.tax_detail = tax_detail
          tax_detail.rescore_contact
        end

        it 'scores correctly' do
          expect(subject.data_integrity_missing_fields).not_to include(
            'de_church_tax',
            'de_health_insurance',
            'de_tax_id',
            'de_tax_number',
            'de_tax_office',
            'de_unemployment_insurance',
            'us_fatca_status',
            'us_tax_form',
            'us_tax_number'
          )
          expect(subject.data_integrity_missing_fields.length).to eq(14)
          expect(subject.data_integrity_score).to be_within(0.0001).of(0.2385)
        end
      end
    end

    describe 'for contact_organization' do
      subject { build(:contact_organization) }
      let!(:tax_detail) { build(:tax_detail, :with_scoreable_organization_data, contact: subject) }

      context 'when rule: specific properties from a related model are filled' do
        before do
          subject.tax_detail = tax_detail
          tax_detail.rescore_contact
        end

        it 'scores correctly' do
          expect(subject.data_integrity_missing_fields).not_to include(
            'de_tax_id',
            'de_tax_number',
            'de_tax_office',
            'legal_entity_identifier',
            'transparency_register',
            'us_fatca_status',
            'us_tax_form',
            'us_tax_number'
          )
          expect(subject.data_integrity_missing_fields.length).to eq(13)
          expect(subject.data_integrity_score).to be_within(0.0001).of(0.1698)
        end
      end
    end
  end
end
