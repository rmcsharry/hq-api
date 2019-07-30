# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scoreable::TaxDetail, bullet: false do
  describe '#rescore_contact' do
    describe 'for contact_person' do
      let!(:subject) { build(:contact_person) }
      let!(:tax_detail) { build(:tax_detail, :with_scoreable_person_data, contact: subject) }

      it 'is correct when rule: specific properties from a related model are filled' do
        subject.tax_detail = tax_detail
        tax_detail.rescore_contact

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

    describe 'for contact_organization' do
      let!(:subject) { build(:contact_organization) }
      let!(:tax_detail) { build(:tax_detail, :with_scoreable_organization_data, contact: subject) }

      it 'is correct when rule: specific properties from a related model are filled' do
        subject.tax_detail = tax_detail
        tax_detail.rescore_contact

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
