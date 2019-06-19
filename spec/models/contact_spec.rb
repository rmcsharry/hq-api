# frozen_string_literal: true

# == Schema Information
#
# Table name: contacts
#
#  comment                    :text
#  commercial_register_number :string
#  commercial_register_office :string
#  created_at                 :datetime         not null
#  date_of_birth              :date
#  date_of_death              :date
#  first_name                 :string
#  gender                     :string
#  id                         :uuid             not null, primary key
#  import_id                  :integer
#  last_name                  :string
#  legal_address_id           :uuid
#  maiden_name                :string
#  nationality                :string
#  nobility_title             :string
#  organization_category      :string
#  organization_industry      :string
#  organization_name          :string
#  organization_type          :string
#  place_of_birth             :string
#  primary_contact_address_id :uuid
#  professional_title         :string
#  type                       :string
#  updated_at                 :datetime         not null
#
# Indexes
#
#  index_contacts_on_legal_address_id            (legal_address_id)
#  index_contacts_on_primary_contact_address_id  (primary_contact_address_id)
#
# Foreign Keys
#
#  fk_rails_...  (legal_address_id => addresses.id)
#  fk_rails_...  (primary_contact_address_id => addresses.id)
#

require 'rails_helper'

RSpec.describe Contact, type: :model do
  it { is_expected.to have_many(:addresses) }
  it { is_expected.to have_many(:contact_details) }
  it { is_expected.to have_many(:mandate_members) }
  it { is_expected.to have_many(:mandates) }
  it { is_expected.to have_many(:active_contact_relationships) }
  it { is_expected.to have_many(:passive_contact_relationships) }
  it { is_expected.to have_many(:investors) }
  it { is_expected.to have_many(:primary_contact_investors) }
  it { is_expected.to have_many(:secondary_contact_investors) }
  it { is_expected.to have_many(:reminders) }
  it { is_expected.to have_many(:list_items).class_name('List::Item').dependent(:destroy).inverse_of(:listable) }
  it { is_expected.to have_many(:lists).through(:list_items) }

  describe '#compliance_detail' do
    it { is_expected.to have_one(:compliance_detail) }
  end

  describe '#tax_detail' do
    it { is_expected.to have_one(:tax_detail) }
  end

  describe '#legal_address' do
    it { is_expected.to belong_to(:legal_address).optional }
  end

  describe '#primary_contact_address' do
    it { is_expected.to belong_to(:primary_contact_address).optional }
  end

  describe '#activities' do
    it { is_expected.to have_and_belong_to_many(:activities) }
  end

  describe '#mandate_member?' do
    context 'as mandate member' do
      let!(:mandate_member) { create(:mandate_member, member_type: 'assistant', contact: subject) }

      it 'returns true' do
        expect(subject.mandate_member?).to eq true
        expect(subject.is_mandate_member).to eq true
      end
    end

    context 'as no mandate member' do
      it 'returns false' do
        expect(subject.mandate_member?).to eq false
        expect(subject.is_mandate_member).to eq false
      end
    end
  end

  describe '#mandate_owner?' do
    context 'as mandate owner' do
      let!(:mandate_member) { create(:mandate_member, member_type: 'owner', contact: subject) }

      it 'returns true' do
        expect(subject.mandate_owner?).to eq true
        expect(subject.is_mandate_owner).to eq true
      end
    end

    context 'as no mandate owner' do
      let!(:mandate_member) { create(:mandate_member, member_type: 'assistant', contact: subject) }

      it 'returns false' do
        expect(subject.mandate_owner?).to eq false
        expect(subject.is_mandate_owner).to eq false
      end
    end
  end

  describe '#associated_to_mandate_with_id?' do
    let!(:mandate) { create :mandate, mandate_members: [] }
    let!(:person) { create :contact_person }
    let!(:uninvolved_person) { create :contact_person }

    it 'finds contacts through primary_consultant' do
      mandate.primary_consultant = person
      mandate.save!

      associated_contacts = Contact.associated_to_mandate_with_id(mandate.id)
      expect(associated_contacts).to include(person)
      expect(associated_contacts).not_to include(uninvolved_person)
    end

    it 'finds contacts through secondary_consultant' do
      mandate.secondary_consultant = person
      mandate.save!

      expect(Contact.associated_to_mandate_with_id(mandate.id)).to include(person)
    end

    it 'finds contacts through bookkeeper' do
      mandate.bookkeeper = person
      mandate.save!

      expect(Contact.associated_to_mandate_with_id(mandate.id)).to include(person)
    end

    it 'finds contacts through assistant' do
      mandate.assistant = person
      mandate.save!

      expect(Contact.associated_to_mandate_with_id(mandate.id)).to include(person)
    end

    describe 'with existing mandate_memberships' do
      let!(:mandate_member) { create :mandate_member, mandate: mandate, contact: person }
      let!(:second_person) { create :contact_person }

      it 'finds contacts through memberships' do
        expect(Contact.associated_to_mandate_with_id(mandate.id)).to include(person)
      end

      it 'finds contacts through memberships and direct associations simultaneously' do
        mandate.assistant = second_person
        mandate.save!

        associated_contacts = Contact.associated_to_mandate_with_id(mandate.id)
        expect(associated_contacts).to include(person)
        expect(associated_contacts).to include(second_person)
      end
    end
  end
end
