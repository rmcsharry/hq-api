# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WeightRulesPerson do
  it 'has the correct number of weights' do
    expect(described_class::WEIGHT_RULES.count).to eql(27)
  end

  it 'has the correct total relative weight' do
    expect(described_class::WEIGHT_RULES.sum { |rule| rule[:relative_weight] }.to_f).to eql(92.25)
  end

  context 'defines correct number of rule types' do
    it 'has 1 activities rule' do
      expect(described_class::WEIGHT_RULES.count { |rule| rule[:model_key] == 'activities' }).to eql(1)
    end

    it 'has 6 compliance detail rules' do
      expect(described_class::WEIGHT_RULES.count { |rule| rule[:model_key] == 'compliance_detail' }).to eql(6)
    end

    it 'has 9 contact person rules' do
      expect(described_class::WEIGHT_RULES.count { |rule| rule[:model_key] == 'contact_person' }).to eql(9)
    end

    it 'has 1 documents rule' do
      expect(described_class::WEIGHT_RULES.count { |rule| rule[:model_key] == 'documents' }).to eql(1)
    end

    it 'has 10 tax detail rules' do
      expect(described_class::WEIGHT_RULES.count { |rule| rule[:model_key] == 'tax_detail' }).to eql(10)
    end
  end
end
