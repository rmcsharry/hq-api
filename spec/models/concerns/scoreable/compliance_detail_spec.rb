# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scoreable::ComplianceDetail, bullet: false do
  describe 'scoreable#calculate_score' do
    describe 'for contact_person' do
      let!(:subject) { build(:contact_person) }

      it 'is correct when rule: specific properties from a related model are filled' do
        subject.compliance_detail = create(:compliance_detail, contact: subject)

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

  describe 'for contact_organization' do
    let!(:subject) { build(:contact_organization) }

    it 'is correct when rule: specific properties from a related model are filled' do
      subject.compliance_detail = create(:compliance_detail, contact: subject)

      expect(subject.data_integrity_missing_fields).not_to include('kagb_classification', 'wphg_classification')
      expect(subject.data_integrity_missing_fields.length).to eq(19)
      expect(subject.data_integrity_score).to be_within(0.0001).of(0.1887)
    end
  end
end
