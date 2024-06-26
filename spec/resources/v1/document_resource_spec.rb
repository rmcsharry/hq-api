# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::DocumentResource, type: :resource do
  let(:document) { create(:document) }
  subject { described_class.new(document, {}) }

  it { is_expected.to have_attribute :category }
  it { is_expected.to have_attribute :created_at }
  it { is_expected.to have_attribute :document_type }
  it { is_expected.to have_attribute :file_name }
  it { is_expected.to have_attribute :file_type }
  it { is_expected.to have_attribute :file_url }
  it { is_expected.to have_attribute :name }
  it { is_expected.to have_attribute :valid_from }
  it { is_expected.to have_attribute :valid_to }

  it { is_expected.to have_one(:owner) }

  it { is_expected.to filter(:document_type) }
  it { is_expected.to filter(:owner_id) }
  it { is_expected.to filter(:state) }
end
