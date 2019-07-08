# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WeightRulesOrganization do
  it 'has the correct number of weights' do
    expect(described_class::WEIGHT_RULES.count).to eql(23)
  end

  it 'has the correct total relative weight' do
    expect(described_class::WEIGHT_RULES.sum { |rule| rule[:relative_weight] }.to_f).to eql(106.0)
  end

  context 'has correct number of different rule types' do
    it 'has 1 activities rule' do
      expect(described_class::WEIGHT_RULES.count { |rule| rule[:model_key] == 'activities' }).to eql(1)
    end

    it 'has 2 compliance detail rules' do
      expect(described_class::WEIGHT_RULES.count { |rule| rule[:model_key] == 'compliance_detail' }).to eql(2)
    end

    it 'has 9 contact organization rules' do
      expect(described_class::WEIGHT_RULES.count { |rule| rule[:model_key] == 'contact_organization' }).to eql(9)
    end

    it 'has 1 documents rule' do
      expect(described_class::WEIGHT_RULES.count { |rule| rule[:model_key] == 'documents' }).to eql(1)
    end

    it 'has 2 relationships rules' do
      expect(described_class::WEIGHT_RULES.count { |rule| rule[:model_key] == 'passive_contact_relationships' })
        .to eql(2)
    end

    it 'has 8 tax detail rules' do
      expect(described_class::WEIGHT_RULES.count { |rule| rule[:model_key] == 'tax_detail' }).to eql(8)
    end
  end
end
