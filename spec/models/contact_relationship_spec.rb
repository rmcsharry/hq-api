# frozen_string_literal: true

# == Schema Information
#
# Table name: contact_relationships
#
#  id                :uuid             not null, primary key
#  role              :string           not null
#  target_contact_id :uuid             not null
#  source_contact_id :uuid             not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  comment           :text
#
# Indexes
#
#  index_contact_relationships_on_source_contact_id  (source_contact_id)
#  index_contact_relationships_on_target_contact_id  (target_contact_id)
#
# Foreign Keys
#
#  fk_rails_...  (source_contact_id => contacts.id)
#  fk_rails_...  (target_contact_id => contacts.id)
#

require 'rails_helper'

RSpec.describe ContactRelationship, type: :model do
  describe '#role' do
    let(:parent) { create :contact_person }
    let(:child) { create :contact_person }
    let(:another_child) { create :contact_person }

    it { is_expected.to validate_presence_of(:role) }
    it { is_expected.to enumerize(:role) }

    it 'validates uniqueness per role and contact set' do
      Bullet.enable = false
      first_parent_relationship = ContactRelationship.create!(
        source_contact: parent,
        target_contact: child,
        role: :parent
      )
      expect(first_parent_relationship).to be_valid

      second_parent_relationship = ContactRelationship.create!(
        source_contact: parent,
        target_contact: another_child,
        role: :parent
      )
      expect(second_parent_relationship).to be_valid

      relationship_duplicate = ContactRelationship.new(
        source_contact: parent,
        target_contact: child,
        role: :parent
      )
      expect(relationship_duplicate).not_to be_valid
      Bullet.enable = true
    end
  end

  describe '#target_contact' do
    it { is_expected.to belong_to(:target_contact).required }
  end

  describe '#source_contact' do
    it { is_expected.to belong_to(:source_contact).required }
  end

  describe '#comment' do
    it { is_expected.to respond_to(:comment) }
  end

  describe 'indirect mandate relationships' do
    let(:parent) { create :contact_person }
    let(:child) { create :contact_person }
    let(:tax_advisor) { create :contact_person }
    let!(:indirect_mandate_relationship) do
      create(:contact_relationship, role: :parent, source_contact: parent, target_contact: child)
    end
    let!(:random_relationship) do
      create(:contact_relationship, role: :tax_advisor, source_contact: tax_advisor, target_contact: parent)
    end
    let(:first_mandate) { create :mandate, mandate_members: [] }
    let(:second_mandate) { create :mandate, mandate_members: [] }
    let!(:direct_mm) { create :mandate_member, mandate: first_mandate, contact: parent, member_type: :owner }
    let!(:first_mm) { create :mandate_member, mandate: first_mandate, contact: child, member_type: :owner }
    let!(:second_mm) { create :mandate_member, mandate: second_mandate, contact: tax_advisor, member_type: :bookkeeper }

    it 'returns contact_relationships to contacts who are owner of a mandate' do
      Bullet.enable = false
      indirect_relationships = ContactRelationship.indirectly_associating_mandates_to_contact_with_id(parent.id)

      expect(indirect_relationships).to match_array([indirect_mandate_relationship])
      Bullet.enable = true
    end
  end

  describe 'person to person relationships' do
    let(:person1) { create :contact_person }
    let(:person2) { create :contact_person }

    it 'may use person-to-person roles' do
      ContactRelationship::PERSON_TO_PERSON_ROLES.each do |valid_role|
        relationship = ContactRelationship.new(
          role: valid_role,
          source_contact: person1,
          target_contact: person2
        )
        expect(relationship).to be_valid
      end
    end

    it 'may not use person-to-organization or organization-to-organization roles' do
      disallowed_roles = [
        *ContactRelationship::PERSON_TO_ORGANIZATION_ROLES,
        *ContactRelationship::ORGANIZATION_TO_ORGANIZATION_ROLES
      ] - ContactRelationship::PERSON_TO_PERSON_ROLES
      disallowed_roles.each do |invalid_role|
        relationship = ContactRelationship.new(
          role: invalid_role,
          source_contact: person1,
          target_contact: person2
        )
        expect(relationship).not_to be_valid
      end
    end
  end

  describe 'person to organization relationships' do
    let(:person) { create :contact_person }
    let(:organization) { create :contact_organization }

    it 'may use person-to-organization roles' do
      ContactRelationship::PERSON_TO_ORGANIZATION_ROLES.each do |valid_role|
        relationship = ContactRelationship.new(
          role: valid_role,
          source_contact: person,
          target_contact: organization
        )
        expect(relationship).to be_valid
      end
    end

    it 'may not use person-to-person or organization-to-organization roles' do
      disallowed_roles = [
        *ContactRelationship::PERSON_TO_PERSON_ROLES,
        *ContactRelationship::ORGANIZATION_TO_ORGANIZATION_ROLES
      ] - ContactRelationship::PERSON_TO_ORGANIZATION_ROLES
      disallowed_roles.each do |invalid_role|
        relationship = ContactRelationship.new(
          role: invalid_role,
          source_contact: person,
          target_contact: organization
        )
        expect(relationship).not_to be_valid
      end
    end
  end

  describe 'organization to organization relationships' do
    let(:organization1) { create :contact_organization }
    let(:organization2) { create :contact_organization }

    it 'may use organization-to-organization roles' do
      ContactRelationship::ORGANIZATION_TO_ORGANIZATION_ROLES.each do |valid_role|
        relationship = ContactRelationship.new(
          role: valid_role,
          source_contact: organization1,
          target_contact: organization2
        )
        expect(relationship).to be_valid
      end
    end

    it 'may not use person-to-person or person-to-organization roles' do
      disallowed_roles = [
        *ContactRelationship::PERSON_TO_PERSON_ROLES,
        *ContactRelationship::PERSON_TO_ORGANIZATION_ROLES
      ] - ContactRelationship::ORGANIZATION_TO_ORGANIZATION_ROLES
      disallowed_roles.each do |invalid_role|
        relationship = ContactRelationship.new(
          role: invalid_role,
          source_contact: organization1,
          target_contact: organization2
        )
        expect(relationship).not_to be_valid
      end
    end
  end

  describe 'organization to person relationships' do
    let(:person) { create :contact_person }
    let(:organization) { create :contact_organization }

    it 'may not exist' do
      disallowed_roles = [
        *ContactRelationship::ORGANIZATION_TO_ORGANIZATION_ROLES,
        *ContactRelationship::PERSON_TO_ORGANIZATION_ROLES,
        *ContactRelationship::PERSON_TO_PERSON_ROLES
      ]
      disallowed_roles.each do |invalid_role|
        relationship = ContactRelationship.new(
          role: invalid_role,
          source_contact: organization,
          target_contact: person
        )
        expect(relationship).not_to be_valid
      end
    end
  end
end
