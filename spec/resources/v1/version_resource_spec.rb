# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::VersionResource, type: :resource do
  let(:contact) { create(:contact_person) }
  subject { described_class.new(contact.versions.first, {}) }

  it { is_expected.to have_attribute :changed_by }
  it { is_expected.to have_attribute :changes }
  it { is_expected.to have_attribute :created_at }
  it { is_expected.to have_attribute :event }
  it { is_expected.to have_attribute :item_id }
  it { is_expected.to have_attribute :item_type }

  it { is_expected.to have_sortable_field :changed_by }
  it { is_expected.to have_sortable_field :changes }
  it { is_expected.to have_sortable_field :created_at }
  it { is_expected.to have_sortable_field :event }
  it { is_expected.to have_sortable_field :item_id }
  it { is_expected.to have_sortable_field :item_type }
end
