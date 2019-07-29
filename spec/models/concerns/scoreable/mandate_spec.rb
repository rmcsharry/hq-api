# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scoreable::Mandate do
  it 'has the correct number of weights' do
    expect(described_class::SCORE_RULES.count).to eql(15)
  end

  it 'has the correct total relative weight' do
    expect(described_class::SCORE_RULES.sum { |rule| rule[:relative_weight] }.to_f).to eql(77.0)
  end

  context 'defines correct number of rule types' do
    it 'has 1 activities rule' do
      expect(described_class::SCORE_RULES.count { |rule| rule[:model_key] == 'activities' }).to eql(1)
    end

    it 'has 1 bank accounts rule' do
      expect(described_class::SCORE_RULES.count { |rule| rule[:model_key] == 'bank_accounts' }).to eql(1)
    end

    it 'has 1 documents rule' do
      expect(described_class::SCORE_RULES.count { |rule| rule[:model_key] == 'documents' }).to eql(1)
    end

    it 'has 7 mandate rules' do
      expect(described_class::SCORE_RULES.count { |rule| rule[:model_key] == 'mandate' }).to eql(7)
    end

    it 'has 5 mandate members rules' do
      expect(described_class::SCORE_RULES.count { |rule| rule[:model_key] == 'mandate_members' }).to eql(5)
    end
  end
end
