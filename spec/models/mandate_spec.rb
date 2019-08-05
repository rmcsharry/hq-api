# frozen_string_literal: true

# == Schema Information
#
# Table name: mandates
#
#  aasm_state                       :string
#  category                         :string
#  comment                          :text
#  confidential                     :boolean          default(FALSE), not null
#  created_at                       :datetime         not null
#  current_state_transition_id      :uuid
#  data_integrity_missing_fields    :string           default([]), is an Array
#  data_integrity_partial_score     :decimal(5, 4)    default(0.0)
#  data_integrity_score             :decimal(5, 4)    default(0.0)
#  datev_creditor_id                :string
#  datev_debitor_id                 :string
#  default_currency                 :string
#  id                               :uuid             not null, primary key
#  import_id                        :integer
#  mandate_number                   :string
#  previous_state_transition_id     :uuid
#  prospect_assets_under_management :decimal(20, 10)
#  prospect_fees_fixed_amount       :decimal(20, 10)
#  prospect_fees_min_amount         :decimal(20, 10)
#  prospect_fees_percentage         :decimal(20, 10)
#  psplus_id                        :string
#  psplus_pe_id                     :string
#  updated_at                       :datetime         not null
#  valid_from                       :date
#  valid_to                         :date
#
# Indexes
#
#  index_mandates_on_current_state_transition_id   (current_state_transition_id)
#  index_mandates_on_data_integrity_score          (data_integrity_score)
#  index_mandates_on_previous_state_transition_id  (previous_state_transition_id)
#
# Foreign Keys
#
#  fk_rails_...  (current_state_transition_id => state_transitions.id)
#  fk_rails_...  (previous_state_transition_id => state_transitions.id)
#
require 'rails_helper'

RSpec.describe Mandate, type: :model do
  include_examples 'state_transitions'

  it { is_expected.to have_many(:mandate_members) }
  it { is_expected.to have_many(:contacts) }
  it { is_expected.to have_many(:investments) }
  it { is_expected.to have_many(:list_items).class_name('List::Item').dependent(:destroy).inverse_of(:listable) }
  it { is_expected.to have_many(:lists).through(:list_items) }

  it { is_expected.to respond_to(:datev_creditor_id) }
  it { is_expected.to respond_to(:datev_debitor_id) }
  it { is_expected.to respond_to(:mandate_number) }
  it { is_expected.to respond_to(:prospect_assets_under_management) }
  it { is_expected.to respond_to(:prospect_fees_fixed_amount) }
  it { is_expected.to respond_to(:prospect_fees_min_amount) }
  it { is_expected.to respond_to(:prospect_fees_percentage) }

  describe 'creation of a mandate' do
    let(:initial_state) { Mandate.aasm.initial_state }
    let(:mandate) { build(:mandate, aasm_state: initial_state) }

    it 'creates an initial StateTransition' do
      mandate.save

      expect(mandate.current_state_transition.state.to_sym).to eq(initial_state)
    end
  end

  describe '#current_state_transition and #previous_state_transition' do
    let(:mandate) { build(:mandate, aasm_state: :prospect_not_qualified) }

    it 'validates for presence of current_state_transition if previous_state_transition exists' do
      Timecop.freeze(2019, 1, 1, 12, 0, 0) do
        mandate.save!
      end

      Timecop.freeze(2019, 1, 1, 12, 0, 1) do
        mandate.become_prospect_warm!
      end

      mandate.current_state_transition = nil
      expect(mandate).not_to be_valid
    end

    it 'returns the current/previous state transition' do
      Timecop.freeze(2019, 1, 1, 12, 0, 0) do
        mandate.save!
      end

      Timecop.freeze(2019, 1, 1, 12, 0, 1) do
        mandate.become_prospect_warm!
      end

      Timecop.freeze(2019, 1, 1, 12, 0, 2) do
        mandate.become_prospect_investment_proposal_created!
      end

      Timecop.freeze(2019, 1, 1, 12, 0, 3) do
        mandate.become_prospect_contract_draft_created!
      end

      mandate.reload

      expect(mandate.state_transitions.count).to eq(4)
      expect(mandate.current_state_transition.state.to_sym).to eq(:prospect_contract_draft_created)
      expect(mandate.previous_state_transition.state.to_sym).to eq(:prospect_investment_proposal_created)
    end
  end

  describe '#permitted_predecessor_states' do
    let(:mandate) { create(:mandate) }

    it 'returns prospect_not_qualified for state == prospect_cold' do
      mandate.update state: :prospect_cold

      expect(mandate.permitted_predecessor_states).to eq([:prospect_not_qualified])
    end

    it 'returns client for state == cancelled' do
      mandate.update state: :cancelled

      expect(mandate.permitted_predecessor_states).to eq([:client])
    end
  end

  describe '#permitted_successor_states' do
    let(:mandate) { create(:mandate) }

    it 'returns prospect_warm for state == prospect_cold' do
      mandate.update state: :prospect_cold

      expect(mandate.permitted_successor_states).to eq(%i[prospect_warm prospect_investment_proposal_created])
    end

    it 'returns cancelled for state == client' do
      mandate.update state: :client

      expect(mandate.permitted_successor_states).to eq(%i[cancelled])
    end

    it 'returns no permitted successor states for state == cancelled' do
      mandate.update state: :cancelled

      expect(mandate.permitted_successor_states).to eq([])
    end
  end

  describe 'aasm state' do
    subject { create :mandate }

    describe 'become_prospect_not_qualified' do
      %i[prospect_cold prospect_warm].each do |state|
        it do
          is_expected.to transition_from(state).to(:prospect_not_qualified).on_event(:degrade_to_prospect_not_qualified)
        end
      end
    end

    describe 'prospect_cold' do
      %i[prospect_not_qualified].each do |state|
        it { is_expected.to transition_from(state).to(:prospect_cold).on_event(:become_prospect_cold) }
      end

      %i[prospect_warm].each do |state|
        it { is_expected.to transition_from(state).to(:prospect_cold).on_event(:degrade_to_prospect_cold) }
      end
    end

    describe 'become_prospect_warm' do
      %i[prospect_cold prospect_not_qualified].each do |state|
        it { is_expected.to transition_from(state).to(:prospect_warm).on_event(:become_prospect_warm) }
      end
    end

    describe 'prospect_investment_proposal_created' do
      %i[prospect_cold prospect_warm].each do |state|
        it do
          is_expected.to transition_from(state)
            .to(:prospect_investment_proposal_created)
            .on_event(:become_prospect_investment_proposal_created)
        end
      end
    end

    describe 'prospect_contract_draft_created' do
      %i[prospect_investment_proposal_created].each do |state|
        it do
          is_expected.to transition_from(state)
            .to(:prospect_contract_draft_created)
            .on_event(:become_prospect_contract_draft_created)
        end
      end

      %i[
        prospect_contract_draft_approved
        prospect_contract_signed
        prospect_contract_countersigned
        prospect_contract_approved
        client
      ].each do |state|
        it do
          is_expected.to transition_from(state)
            .to(:prospect_contract_draft_created)
            .on_event(:degrade_to_prospect_contract_draft_created)
        end
      end
    end

    describe 'prospect_contract_draft_approved' do
      %i[prospect_contract_draft_created].each do |state|
        it do
          is_expected.to transition_from(state)
            .to(:prospect_contract_draft_approved)
            .on_event(:become_prospect_contract_draft_approved)
        end
      end
    end

    describe 'prospect_contract_signed' do
      %i[prospect_contract_draft_approved].each do |state|
        it do
          is_expected.to transition_from(state)
            .to(:prospect_contract_signed)
            .on_event(:become_prospect_contract_signed)
        end
      end
    end

    describe 'prospect_contract_countersigned' do
      %i[prospect_contract_signed].each do |state|
        it do
          is_expected.to transition_from(state)
            .to(:prospect_contract_countersigned)
            .on_event(:become_prospect_contract_countersigned)
        end
      end
    end

    describe 'prospect_contract_approved' do
      %i[prospect_contract_countersigned].each do |state|
        it do
          is_expected.to transition_from(state)
            .to(:prospect_contract_approved)
            .on_event(:become_prospect_contract_approved)
        end
      end
    end

    describe 'client' do
      context 'when #primary_and_secondary_consultant_present? is true' do
        %i[prospect_contract_approved].each do |state|
          subject { build(:mandate, aasm_state: state) }
          it { is_expected.to transition_from(state).to(:client).on_event(:become_client) }
        end
      end

      context 'when #primary_and_secondary_consultant_present? is false' do
        %i[prospect_contract_approved].each do |state|
          subject do
            build(:mandate, aasm_state: state, mandate_members: [])
          end
          it { is_expected.not_to allow_event(:become_client) }
        end
      end
    end

    describe 'cancelled' do
      %i[client].each do |state|
        it { is_expected.to transition_from(state).to(:cancelled).on_event(:become_cancelled) }
      end
    end
  end

  describe '#psplus_id' do
    it { is_expected.to respond_to(:psplus_id) }
    it { is_expected.to validate_length_of(:psplus_id).is_at_most(15) }
  end

  describe '#psplus_pe_id' do
    it { is_expected.to respond_to(:psplus_pe_id) }
    it { is_expected.to validate_length_of(:psplus_pe_id).is_at_most(15) }
  end

  describe '#category' do
    it { is_expected.to validate_presence_of(:category) }
    it { is_expected.to enumerize(:category) }
  end

  describe '#data_integrity_missing_fields' do
    it { is_expected.to respond_to(:data_integrity_missing_fields) }
  end

  describe '#data_integrity_partial_score' do
    it { is_expected.to respond_to(:data_integrity_partial_score) }
    it { is_expected.to validate_numericality_of(:data_integrity_partial_score).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:data_integrity_partial_score).is_less_than_or_equal_to(1) }
  end

  describe '#data_integrity_score' do
    it { is_expected.to respond_to(:data_integrity_score) }
    it { is_expected.to validate_numericality_of(:data_integrity_score).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:data_integrity_score).is_less_than_or_equal_to(1) }
  end

  describe '#default_currency' do
    subject { create(:mandate, prospect_assets_under_management: 1_000_000, default_currency: 'EUR') }
    it { is_expected.to enumerize(:default_currency) }
    it { is_expected.to validate_presence_of(:default_currency) }
  end

  describe '#mandate_groups' do
    let!(:family) { create(:mandate_group, group_type: 'family', mandates: [subject]) }
    let!(:organization) { create(:mandate_group, group_type: 'organization', mandates: [subject]) }
    subject { create(:mandate) }

    it { is_expected.to have_and_belong_to_many(:mandate_groups) }
    it { is_expected.to have_and_belong_to_many(:mandate_groups_families) }
    it { is_expected.to have_and_belong_to_many(:mandate_groups_organizations) }
    it { is_expected.to validate_presence_of(:mandate_groups_organizations) }

    it 'filters as expected' do
      subject.reload
      expect(subject.mandate_groups).to include(family, organization)
      expect(subject.mandate_groups_families).to include(family)
      expect(subject.mandate_groups_families).to_not include(organization)
      expect(subject.mandate_groups_organizations).to include(organization)
      expect(subject.mandate_groups_organizations).to_not include(family)
    end
  end

  describe '#activities' do
    it { is_expected.to have_and_belong_to_many(:activities) }
  end

  describe '#primary_consultant' do
    context 'for client' do
      subject { build(:mandate, aasm_state: :client) }
      let(:primary_consultant) { build :mandate_member, mandate: subject, member_type: :primary_consultant }
      let(:primary_consultant_2) { build :mandate_member, mandate: subject, member_type: :primary_consultant }

      it 'is required' do
        subject.mandate_members = []
        expect(subject).not_to be_valid

        subject.mandate_members << primary_consultant
        expect(subject.reload).to be_valid
      end

      it 'can only exist once' do
        subject.mandate_members = []
        expect(subject).not_to be_valid

        subject.mandate_members << primary_consultant
        subject.mandate_members << primary_consultant_2
        expect(subject).not_to be_valid
      end
    end

    context 'for prospect_not_qualified' do
      subject { build(:mandate, aasm_state: :prospect_contract_approved, mandate_members: []) }
      let(:primary_consultant) { build :mandate_member, mandate: subject, member_type: :primary_consultant }
      let(:secondary_consultant) { build :mandate_member, mandate: subject, member_type: :secondary_consultant }

      it 'is optional' do
        subject.mandate_members = []
        expect(subject).to be_valid
      end

      it 'can be converted to client if primary consultant is set' do
        subject.mandate_members << primary_consultant
        subject.mandate_members << secondary_consultant
        subject.state = :prospect_contract_approved
        subject.save
        expect(subject.reload.may_become_client?).to be_truthy
      end
    end
  end

  describe '#valid_to_greater_or_equal_valid_from' do
    subject { build(:mandate, valid_from: valid_from, valid_to: valid_to) }
    let(:valid_from) { 5.days.ago }
    let(:valid_to) { Time.zone.today }

    context 'valid_to after valid_from' do
      it 'is valid' do
        expect(subject).to be_valid
      end
    end

    context 'valid_to is not set' do
      let(:valid_to) { nil }

      it 'is valid' do
        expect(subject).to be_valid
      end
    end

    context 'valid_from is not set' do
      let(:valid_from) { nil }

      it 'is valid' do
        expect(subject).to be_valid
      end
    end

    context 'valid_to before valid_from' do
      let(:valid_to) { valid_from - 1.day }

      it 'is invalid' do
        expect(subject).to be_invalid
        expect(subject.errors.messages[:valid_to]).to include("can't be before valid_from")
      end
    end

    context 'valid_to on valid_from' do
      let(:valid_to) { valid_from }

      it 'is valid' do
        expect(subject).to be_valid
      end
    end
  end

  describe '#with_owner_name' do
    let(:person1) { create(:contact_person, first_name: 'Thomas', last_name: 'Makait') }
    let(:person2) { create(:contact_person, first_name: 'Maria', last_name: 'Makait') }
    let(:organization) { create(:contact_organization, organization_name: 'Novo Investments UG') }
    let(:mandate_member1) { create(:mandate_member, contact: person1, member_type: 'owner') }
    let(:mandate_member2) { create(:mandate_member, contact: person2, member_type: 'owner') }
    let(:mandate_member3) { create(:mandate_member, contact: organization, member_type: 'owner') }
    subject! { create(:mandate, mandate_members: owners) }

    context 'all three are owners' do
      let(:owners) { [mandate_member1, mandate_member2, mandate_member3] }
      it 'responds with all names' do
        expect(Mandate.all.with_owner_name.find(subject.id).owner_name).to eq(
          'Makait, Maria, Makait, Thomas, Novo Investments UG'
        )
      end
    end

    context 'person1 is owner' do
      let(:owners) { [mandate_member1] }
      it "responds with person1's name" do
        expect(Mandate.all.with_owner_name.find(subject.id).owner_name).to eq 'Makait, Thomas'
      end
    end

    context 'person1 and person2 are owners' do
      let(:owners) { [mandate_member1, mandate_member2] }
      it "responds with person1 and person2's names" do
        expect(Mandate.all.with_owner_name.find(subject.id).owner_name).to eq 'Makait, Maria, Makait, Thomas'
      end
    end

    context 'organization is owner' do
      let(:owners) { [mandate_member3] }
      it "responds with the organization's name" do
        expect(Mandate.all.with_owner_name.find(subject.id).owner_name).to eq 'Novo Investments UG'
      end
    end

    context 'nobody is owner' do
      let(:owners) { [] }
      it 'responds with nil' do
        expect(Mandate.all.with_owner_name.find(subject.id).owner_name).to eq nil
      end
    end
  end

  describe '#associated_to_contact_with_id' do
    let(:person) { create(:contact_person, first_name: 'Thomas', last_name: 'Makait') }
    let!(:random_mandate) { create(:mandate) }
    subject! { mandate }

    context 'when person is not associated' do
      let(:mandate) { create(:mandate) }

      it 'does not find any associated mandates' do
        associated_mandates = Mandate.associated_to_contact_with_id(person.id)
        expect(associated_mandates.count).to eq(0)
      end
    end

    context 'when person is primary_consultant' do
      let(:mandate) { create(:mandate, mandate_members: [], primary_consultant: person) }

      it 'finds associated mandate' do
        associated_mandates = Mandate.associated_to_contact_with_id(person.id)
        expect(associated_mandates.count).to eq(1)
        expect(associated_mandates.first).to eq(mandate)
      end
    end

    context 'when person is secondary_consultant' do
      let(:mandate) { create(:mandate, mandate_members: [], secondary_consultant: person) }

      it 'finds associated mandate' do
        associated_mandates = Mandate.associated_to_contact_with_id(person.id)
        expect(associated_mandates.count).to eq(1)
        expect(associated_mandates.first).to eq(mandate)
      end
    end

    context 'when person is assistant' do
      let(:mandate) { create(:mandate, mandate_members: [], assistant: person) }

      it 'finds associated mandate' do
        associated_mandates = Mandate.associated_to_contact_with_id(person.id)
        expect(associated_mandates.count).to eq(1)
        expect(associated_mandates.first).to eq(mandate)
      end
    end

    context 'when person is bookkeeper' do
      let(:mandate) { create(:mandate, mandate_members: [], bookkeeper: person) }

      it 'finds associated mandate' do
        associated_mandates = Mandate.associated_to_contact_with_id(person.id)
        expect(associated_mandates.count).to eq(1)
        expect(associated_mandates.first).to eq(mandate)
      end
    end
  end

  describe 'task count associated to current state' do
    let(:user) { build(:user) }
    let(:mandate) { build(:mandate, aasm_state: :prospect_not_qualified) }
    let(:task_1) { build(:task, subject: mandate) }
    let(:task_2) { build(:task, subject: mandate) }
    let(:task_3) { build(:task, subject: mandate) }

    before do
      Timecop.freeze(2019, 1, 1, 12, 0, 0) do
        mandate.save!
        task_1.save!
      end

      Timecop.freeze(2019, 1, 1, 12, 0, 1) do
        mandate.become_prospect_warm!
        task_2.save!
        task_3.save!
      end

      Timecop.freeze(2019, 1, 1, 12, 0, 2) do
        task_1.finish!(user)
        task_2.finish!(user)
      end
    end

    after do
      Timecop.return
    end

    describe '#current_state_completed_tasks_count' do
      it 'returns number of completed tasks of the current state' do
        expect(mandate.current_state_completed_tasks_count).to eq(1)
      end
    end

    describe '#current_state_total_tasks_count' do
      it 'returns number of tasks of the current state' do
        expect(mandate.current_state_total_tasks_count).to eq(2)
      end
    end
  end
end
