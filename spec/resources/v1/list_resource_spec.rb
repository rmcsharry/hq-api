# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::ListResource, type: :resource do
  let(:list) { create(:list) }
  subject { described_class.new(list, {}) }

  it { is_expected.to have_many(:contacts) }
  it { is_expected.to have_many(:mandates) }

  it { is_expected.to have_attribute(:comment) }
  it { is_expected.to have_attribute(:contact_count) }
  it { is_expected.to have_attribute(:mandate_count) }
  it { is_expected.to have_attribute(:name) }
  it { is_expected.to have_attribute(:state) }
  it { is_expected.to have_attribute(:updated_at) }
  it { is_expected.to have_attribute(:user_name) }

  it { is_expected.to filter(:listable_not_in_list) }
  it { is_expected.to filter(:name) }
  it { is_expected.to filter(:state) }

  it { is_expected.to have_sortable_field(:contact_count) }
  it { is_expected.to have_sortable_field(:mandate_count) }
end
