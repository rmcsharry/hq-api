# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::ListItemResource, type: :resource do
  let(:list_item) { create(:list_item, :for_contact_person) }
  subject { described_class.new(list_item, {}) }

  it { is_expected.to have_one(:list) }

  it { is_expected.to have_attribute(:category) }
  it { is_expected.to have_attribute(:comment) }
  it { is_expected.to have_attribute(:listable_id) }
  it { is_expected.to have_attribute(:listable_type) }
  it { is_expected.to have_attribute(:name) }

  it { is_expected.to filter(:'list.state') }
  it { is_expected.to filter(:list_id) }
  it { is_expected.to filter(:listable_id) }
  it { is_expected.to filter(:listable_type) }

  it { is_expected.to have_sortable_field(:'list.name') }
  it { is_expected.to have_sortable_field(:category) }
  it { is_expected.to have_sortable_field(:name) }
end
