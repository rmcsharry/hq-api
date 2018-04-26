# frozen_string_literal: true

# == Schema Information
#
# Table name: mandates
#
#  id                      :uuid             not null, primary key
#  aasm_state              :string
#  category                :string
#  comment                 :text
#  valid_from              :date
#  valid_to                :date
#  datev_creditor_id       :string
#  datev_debitor_id        :string
#  psplus_id               :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  primary_consultant_id   :uuid
#  secondary_consultant_id :uuid
#  assistant_id            :uuid
#  bookkeeper_id           :uuid
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
  it { is_expected.to belong_to(:assistant).optional }
  it { is_expected.to belong_to(:bookkeeper).optional }
  it { is_expected.to have_many(:mandate_members) }
  it { is_expected.to have_many(:contacts) }

  describe '#category' do
    it { is_expected.to validate_presence_of(:category) }
    it { is_expected.to enumerize(:category) }
  end

  describe '#mandate_groups' do
    it { is_expected.to have_and_belong_to_many(:mandate_groups) }
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

    context 'for prospect' do
      subject { build(:mandate, aasm_state: :prospect, primary_consultant: nil) }
      it 'is optional' do
        expect(subject).to belong_to(:primary_consultant).optional
      end
      it 'can be converted to client if primary consultant is set' do
        subject.primary_consultant = build(:contact_person)
        expect(subject.may_become_client?).to be_truthy
      end
    end
  end

  describe '#secondary_consultant' do
    context 'for client' do
      subject { build(:mandate, aasm_state: :client) }
      it 'is required' do
        expect(subject).to validate_presence_of(:secondary_consultant)
      end
    end

    context 'for prospect' do
      subject { build(:mandate, aasm_state: :prospect, secondary_consultant: nil) }
      it 'is optional' do
        expect(subject).to belong_to(:secondary_consultant).optional
      end
      it 'can be converted to client if secondary consultant is set' do
        subject.secondary_consultant = build(:contact_person)
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
          'Thomas Makait, Maria Makait, Novo Investments UG'
        )
      end
    end

    context 'person1 is owner' do
      let(:owners) { [mandate_member1] }
      it "responds with person1's name" do
        expect(Mandate.all.with_owner_name.find(subject.id).owner_name).to eq 'Thomas Makait'
      end
    end

    context 'person1 and person2 are owners' do
      let(:owners) { [mandate_member1, mandate_member2] }
      it "responds with person1 and person2's names" do
        expect(Mandate.all.with_owner_name.find(subject.id).owner_name).to eq 'Thomas Makait, Maria Makait'
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
end
