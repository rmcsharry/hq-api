# frozen_string_literal: true

# == Schema Information
#
# Table name: contacts
#
#  id                         :uuid             not null, primary key
#  first_name                 :string
#  last_name                  :string
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  type                       :string
#  comment                    :text
#  gender                     :string
#  nobility_title             :string
#  professional_title         :string
#  maiden_name                :string
#  date_of_birth              :date
#  date_of_death              :date
#  nationality                :string
#  organization_name          :string
#  organization_type          :string
#  organization_category      :string
#  organization_industry      :string
#  commercial_register_number :string
#  commercial_register_office :string
#  legal_address_id           :uuid
#  primary_contact_address_id :uuid
#  import_id                  :integer
#  place_of_birth             :string
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
  it { is_expected.to have_many(:organization_members) }
  it { is_expected.to have_many(:organizations) }
  it { is_expected.to have_many(:active_person_relationships) }
  it { is_expected.to have_many(:passive_person_relationships) }
  it { is_expected.to have_many(:actively_related_persons) }
  it { is_expected.to have_many(:passively_related_persons) }
  it { is_expected.to have_many(:investors) }
  it { is_expected.to have_many(:primary_consultant_mandates) }
  it { is_expected.to have_many(:secondary_consultant_mandates) }
  it { is_expected.to have_many(:primary_contact_investors) }
  it { is_expected.to have_many(:secondary_contact_investors) }
  it { is_expected.to have_many(:reminders) }

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
      let!(:mandate_member) { create(:mandate_member, member_type: 'advisor', contact: subject) }

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
      let!(:mandate_member) { create(:mandate_member, member_type: 'advisor', contact: subject) }

      it 'returns false' do
        expect(subject.mandate_owner?).to eq false
        expect(subject.is_mandate_owner).to eq false
      end
    end
  end

  describe '#associated_to_mandate_with_id?' do
    let!(:mandate) { create :mandate }
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
