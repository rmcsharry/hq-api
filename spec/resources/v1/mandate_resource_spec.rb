# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::MandateResource, type: :resource do
  let(:mandate) { create(:mandate) }
  subject { described_class.new(mandate, {}) }

  it { is_expected.to have_attribute :category }
  it { is_expected.to have_attribute :comment }
  it { is_expected.to have_attribute :confidential }
  it { is_expected.to have_attribute :current_state_completed_tasks_count }
  it { is_expected.to have_attribute :current_state_total_tasks_count }
  it { is_expected.to have_attribute :data_integrity_missing_fields }
  it { is_expected.to have_attribute :data_integrity_partial_score }
  it { is_expected.to have_attribute :data_integrity_score }
  it { is_expected.to have_attribute :datev_creditor_id }
  it { is_expected.to have_attribute :datev_debitor_id }
  it { is_expected.to have_attribute :default_currency }
  it { is_expected.to have_attribute :mandate_number }
  it { is_expected.to have_attribute :permitted_predecessor_states }
  it { is_expected.to have_attribute :permitted_successor_states }
  it { is_expected.to have_attribute :prospect_assets_under_management }
  it { is_expected.to have_attribute :prospect_fees_fixed_amount }
  it { is_expected.to have_attribute :prospect_fees_min_amount }
  it { is_expected.to have_attribute :prospect_fees_percentage }
  it { is_expected.to have_attribute :psplus_id }
  it { is_expected.to have_attribute :psplus_pe_id }
  it { is_expected.to have_attribute :state }
  it { is_expected.to have_attribute :valid_from }
  it { is_expected.to have_attribute :valid_to }

  it { is_expected.to have_many(:bank_accounts) }
  it { is_expected.to have_many(:documents) }
  it { is_expected.to have_many(:investors) }
  it { is_expected.to have_many(:mandate_groups) }
  it { is_expected.to have_many(:mandate_groups_families) }
  it { is_expected.to have_many(:mandate_groups_organizations) }
  it { is_expected.to have_many(:mandate_members) }
  it { is_expected.to have_many(:state_transitions) }

  it { is_expected.to have_one(:assistant).with_class_name('Contact') }
  it { is_expected.to have_one(:bookkeeper).with_class_name('Contact') }
  it { is_expected.to have_one(:current_state_transition).with_class_name('StateTransition') }
  it { is_expected.to have_one(:previous_state_transition).with_class_name('StateTransition') }
  it { is_expected.to have_one(:primary_consultant).with_class_name('Contact') }
  it { is_expected.to have_one(:secondary_consultant).with_class_name('Contact') }

  it { is_expected.to filter(:"assistant.name") }
  it { is_expected.to filter(:"bookkeeper.name") }
  it { is_expected.to filter(:"primary_consultant.name") }
  it { is_expected.to filter(:"secondary_consultant.name") }
  it { is_expected.to filter(:category) }
  it { is_expected.to filter(:datev_creditor_id) }
  it { is_expected.to filter(:data_integrity_score_min) }
  it { is_expected.to filter(:data_integrity_score_max) }
  it { is_expected.to filter(:datev_debitor_id) }
  it { is_expected.to filter(:default_currency) }
  it { is_expected.to filter(:mandate_group_id) }
  it { is_expected.to filter(:mandate_groups_organizations) }
  it { is_expected.to filter(:mandate_number) }
  it { is_expected.to filter(:not_in_list_with_id) }
  it { is_expected.to filter(:owner_name) }
  it { is_expected.to filter(:prospect_assets_under_management) }
  it { is_expected.to filter(:prospect_assets_under_management_max) }
  it { is_expected.to filter(:prospect_assets_under_management_min) }
  it { is_expected.to filter(:prospect_fees_fixed_amount) }
  it { is_expected.to filter(:prospect_fees_fixed_amount_max) }
  it { is_expected.to filter(:prospect_fees_fixed_amount_min) }
  it { is_expected.to filter(:prospect_fees_min_amount) }
  it { is_expected.to filter(:prospect_fees_min_amount_max) }
  it { is_expected.to filter(:prospect_fees_min_amount_min) }
  it { is_expected.to filter(:prospect_fees_percentage) }
  it { is_expected.to filter(:prospect_fees_percentage_max) }
  it { is_expected.to filter(:prospect_fees_percentage_min) }
  it { is_expected.to filter(:psplus_id) }
  it { is_expected.to filter(:psplus_pe_id) }
  it { is_expected.to filter(:state) }
  it { is_expected.to filter(:valid_from_max) }
  it { is_expected.to filter(:valid_from_min) }
  it { is_expected.to filter(:valid_to_max) }
  it { is_expected.to filter(:valid_to_min) }

  it { is_expected.to have_sortable_field(:"primary_consultant.name") }
  it { is_expected.to have_sortable_field(:"secondary_consultant.name") }
  it { is_expected.to have_sortable_field(:"assistant.name") }
  it { is_expected.to have_sortable_field(:"bookkeeper.name") }
  it { is_expected.to have_sortable_field(:data_integrity_score) }
end
