require 'rails_helper'

RSpec.describe V1::DocumentResource, type: :resource do
  let(:document) { create(:document) }
  subject { described_class.new(document, {}) }

  it { is_expected.to have_attribute :name }
  it { is_expected.to have_attribute :category }
  it { is_expected.to have_attribute :valid_from }
  it { is_expected.to have_attribute :valid_to }

  it { is_expected.to have_one(:owner) }
end
