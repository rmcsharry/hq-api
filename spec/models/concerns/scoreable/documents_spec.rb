# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scoreable::Document, bullet: false do
  describe 'scoreable#calculate_score' do
    describe 'for contact_person' do
      let!(:subject) { build(:contact_person) }

      it 'is correct when rule: a related model property has a specific value' do
        subject.documents << build(:document, category: 'kyc')
        # subject.save # needed to ensure the document type is found by the algorithm
        # subject.calculate_score

        expect(subject.data_integrity_missing_fields).not_to include('kyc')
        expect(subject.data_integrity_missing_fields.length).to eq(23)
        expect(subject.data_integrity_score).to be_within(0.0001).of(0.271)
      end
    end

    describe 'for contact_organization' do
      let!(:subject) { build(:contact_organization) }

      it 'is correct when rule: a related model property has a specific value' do
        subject.documents << build(:document, category: 'kyc')
        # subject.save # needed to ensure the document type is found by the algorithm
        # subject.calculate_score

        expect(subject.data_integrity_missing_fields).not_to include('kyc')
        expect(subject.data_integrity_missing_fields.length).to eq(20)
        expect(subject.data_integrity_score).to be_within(0.0001).of(0.1887)
      end
    end

    describe 'for mandate' do
      let!(:subject) { build(:mandate) }

      it 'is correct when rule: a related model property has a specific value' do
        subject.documents << build(:document, category: 'contract_hq')

        expect(subject.data_integrity_missing_fields).not_to include('contract_hq')
        expect(subject.data_integrity_missing_fields.length).to eq(10)
        expect(subject.data_integrity_partial_score).to be_within(0.0001).of(0.4545)
      end
    end
  end
end
