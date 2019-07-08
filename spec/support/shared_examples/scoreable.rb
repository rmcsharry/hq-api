# frozen_string_literal: true

require 'rails_helper'

shared_examples_for 'scoreable' do
  it 'sums total relative weights' do
    total = described_class::WEIGHT_RULES.sum { |rule| rule[:relative_weight] }.to_f
    expect(described_class.relative_weights_total).to eq(total)
  end
end
