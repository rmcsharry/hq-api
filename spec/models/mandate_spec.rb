# frozen_string_literal: true

# == Schema Information
#
# Table name: mandates
#
#  aasm_state                       :string
#  assistant_id                     :uuid
#  bookkeeper_id                    :uuid
#  category                         :string
#  comment                          :text
#  confidential                     :boolean          default(FALSE), not null
#  created_at                       :datetime         not null
#  datev_creditor_id                :string
#  datev_debitor_id                 :string
#  default_currency                 :string
#  id                               :uuid             not null, primary key
#  import_id                        :integer
#  mandate_number                   :string
#  primary_consultant_id            :uuid
#  prospect_assets_under_management :decimal(20, 10)
#  prospect_fees_fixed_amount       :decimal(20, 10)
#  prospect_fees_min_amount         :decimal(20, 10)
#  prospect_fees_percentage         :decimal(20, 10)
#  psplus_id                        :string
#  psplus_pe_id                     :string
#  secondary_consultant_id          :uuid
#  updated_at                       :datetime         not null
#  valid_from                       :date
#  valid_to                         :date
#
# Indexes
#
#  index_mandates_on_assistant_id             (assistant_id)
#  index_mandates_on_bookkeeper_id            (bookkeeper_id)
#  index_mandates_on_primary_consultant_id    (primary_consultant_id)
#  index_mandates_on_secondary_consultant_id  (secondary_consultant_id)
#
# Foreign Keys
#
#  fk_rails_...  (assistant_id => contacts.id)
#  fk_rails_...  (bookkeeper_id => contacts.id)
#  fk_rails_...  (primary_consultant_id => contacts.id)
#  fk_rails_...  (secondary_consultant_id => contacts.id)
#

require 'rails_helper'

RSpec.describe Mandate, type: :model do
  it { is_expected.to belong_to(:secondary_consultant).optional }
  it { is_expected.to belong_to(:assistant).optional }
  it { is_expected.to belong_to(:bookkeeper).optional }
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

  describe 'aasm events' do
    describe 'become_client' do
      context 'when #primary_and_secondary_consultant_present? is true' do
        %i[cancelled prospect_cold prospect_not_qualified prospect_warm].each do |state|
          subject { build(:mandate, aasm_state: state) }
          it { is_expected.to transition_from(state).to(:client).on_event(:become_client) }
        end
      end

      context 'when #primary_and_secondary_consultant_present? is false' do
        %i[cancelled prospect_cold prospect_not_qualified prospect_warm].each do |state|
          subject { build(:mandate, aasm_state: state, primary_consultant: nil) }
          it { is_expected.to_not allow_event(:become_client) }
        end
      end
    end

    describe 'cancel' do
      %i[client prospect_cold prospect_not_qualified prospect_warm].each do |state|
        it { is_expected.to transition_from(state).to(:cancelled).on_event(:cancel) }
      end
    end

    describe 'become_prospect_not_qualified' do
      %i[cancelled client prospect_cold prospect_warm].each do |state|
        it {
          is_expected.to transition_from(state).to(:prospect_not_qualified).on_event(:become_prospect_not_qualified)
        }
      end
    end

    describe 'become_prospect_cold' do
      %i[cancelled client prospect_not_qualified prospect_warm].each do |state|
        it { is_expected.to transition_from(state).to(:prospect_cold).on_event(:become_prospect_cold) }
      end
    end

    describe 'become_prospect_warm' do
      %i[cancelled client prospect_cold prospect_not_qualified].each do |state|
        it { is_expected.to transition_from(state).to(:prospect_warm).on_event(:become_prospect_warm) }
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
      it 'is required' do
        expect(subject).to validate_presence_of(:primary_consultant)
      end
    end

    context 'for prospect_not_qualified' do
      subject { build(:mandate, aasm_state: :prospect_not_qualified, primary_consultant: nil) }
      it 'is optional' do
        expect(subject).to belong_to(:primary_consultant).optional
      end
      it 'can be converted to client if primary consultant is set' do
        subject.primary_consultant = build(:contact_person)
        expect(subject.may_become_client?).to be_truthy
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
      let(:mandate) { create(:mandate, primary_consultant: person) }

      it 'finds associated mandate' do
        associated_mandates = Mandate.associated_to_contact_with_id(person.id)
        expect(associated_mandates.count).to eq(1)
        expect(associated_mandates.first).to eq(mandate)
      end
    end

    context 'when person is secondary_consultant' do
      let(:mandate) { create(:mandate, secondary_consultant: person) }

      it 'finds associated mandate' do
        associated_mandates = Mandate.associated_to_contact_with_id(person.id)
        expect(associated_mandates.count).to eq(1)
        expect(associated_mandates.first).to eq(mandate)
      end
    end

    context 'when person is assistant' do
      let(:mandate) { create(:mandate, assistant: person) }

      it 'finds associated mandate' do
        associated_mandates = Mandate.associated_to_contact_with_id(person.id)
        expect(associated_mandates.count).to eq(1)
        expect(associated_mandates.first).to eq(mandate)
      end
    end

    context 'when person is bookkeeper' do
      let(:mandate) { create(:mandate, bookkeeper: person) }

      it 'finds associated mandate' do
        associated_mandates = Mandate.associated_to_contact_with_id(person.id)
        expect(associated_mandates.count).to eq(1)
        expect(associated_mandates.first).to eq(mandate)
      end
    end
  end
end
