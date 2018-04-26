# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::MandateResource, type: :resource do
  let(:mandate) { create(:mandate) }
  subject { described_class.new(mandate, {}) }

  it { is_expected.to have_attribute :state }
  it { is_expected.to have_attribute :category }
  it { is_expected.to have_attribute :comment }
  it { is_expected.to have_attribute :valid_from }
  it { is_expected.to have_attribute :valid_to }
  it { is_expected.to have_attribute :datev_creditor_id }
  it { is_expected.to have_attribute :datev_debitor_id }
  it { is_expected.to have_attribute :psplus_id }

  it { is_expected.to have_many(:bank_accounts) }
  it { is_expected.to have_many(:documents) }
  it { is_expected.to have_many(:mandate_groups) }
  it { is_expected.to have_many(:mandate_groups_families) }
  it { is_expected.to have_many(:mandate_groups_organizations) }
  it { is_expected.to have_many(:mandate_members) }
  it { is_expected.to have_one(:primary_consultant).with_class_name('Contact') }
  it { is_expected.to have_one(:secondary_consultant).with_class_name('Contact') }
  it { is_expected.to have_one(:assistant).with_class_name('Contact') }
  it { is_expected.to have_one(:bookkeeper).with_class_name('Contact') }

  it { is_expected.to filter(:"assistant.name") }
  it { is_expected.to filter(:"bookkeeper.name") }
  it { is_expected.to filter(:"primary_consultant.name") }
  it { is_expected.to filter(:"secondary_consultant.name") }
  it { is_expected.to filter(:category) }
  it { is_expected.to filter(:mandate_group_id) }
  it { is_expected.to filter(:mandate_groups_organizations) }
  it { is_expected.to filter(:owner_name) }
  it { is_expected.to filter(:state) }
  it { is_expected.to filter(:valid_from_max) }
  it { is_expected.to filter(:valid_from_min) }
  it { is_expected.to filter(:valid_to_max) }
  it { is_expected.to filter(:valid_to_min) }
end
