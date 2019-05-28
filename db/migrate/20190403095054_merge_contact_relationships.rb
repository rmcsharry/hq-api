class Contact < ApplicationRecord
  has_many(
    :active_person_relationships, class_name: 'InterPersonRelationship', dependent: :destroy,
                                  inverse_of: :source_person, foreign_key: :source_person_id
  )
  has_many(
    :passive_person_relationships, class_name: 'InterPersonRelationship', dependent: :destroy,
                                   inverse_of: :target_person, foreign_key: :target_person_id
  )
  has_many(
    :organization_members,
    class_name: 'OrganizationMember',
    foreign_key: :organization,
    dependent: :destroy,
    inverse_of: :organization
  )
  has_many(
    :contact_members,
    class_name: 'OrganizationMember',
    foreign_key: :contact,
    dependent: :destroy,
    inverse_of: :contact
  )
  has_many(
    :active_contact_relationships,
    class_name: 'ContactRelationship',
    dependent: :destroy,
    foreign_key: :source_contact_id,
    inverse_of: :source_contact
  )
  has_many(
    :passive_contact_relationships,
    class_name: 'ContactRelationship',
    dependent: :destroy,
    foreign_key: :target_contact_id,
    inverse_of: :target_contact
  )
end
class InterPersonRelationship < ApplicationRecord
  belongs_to :target_person, class_name: 'Contact::Person', inverse_of: :passive_person_relationships
  belongs_to :source_person, class_name: 'Contact::Person', inverse_of: :active_person_relationships
end
class OrganizationMember < ApplicationRecord
  belongs_to :contact, inverse_of: :organization_members
  belongs_to :organization, class_name: 'Contact::Organization', inverse_of: :contact_members
end
class Contact::Person < Contact
end
class Contact::Organization < Contact
  has_many(
    :active_person_relationships, class_name: 'InterPersonRelationship', dependent: :destroy,
                                  inverse_of: :source_person, foreign_key: :source_person_id
  )
  has_many(
    :passive_person_relationships, class_name: 'InterPersonRelationship', dependent: :destroy,
                                   inverse_of: :target_person, foreign_key: :target_person_id
  )
  has_many(
    :organization_members,
    class_name: 'OrganizationMember',
    foreign_key: :organization,
    dependent: :destroy,
    inverse_of: :organization
  )
  has_many(
    :contact_members,
    class_name: 'OrganizationMember',
    foreign_key: :contact,
    dependent: :destroy,
    inverse_of: :contact
  )
end

class MergeContactRelationships < ActiveRecord::Migration[5.2]
  def change
    create_table :contact_relationships, id: :uuid do |t|
      t.string :role, null: false
      t.belongs_to :source_contact, index: true, foreign_key: { to_table: :contacts }, type: :uuid, null: false
      t.belongs_to :target_contact, index: true, foreign_key: { to_table: :contacts }, type: :uuid, null: false

      t.timestamps
    end

    person_mappings = {
      acquaintance: { new_role: :acquaintance, switch_target: false },
      architect: { new_role: :architect, switch_target: false },
      architect_client: { new_role: :architect, switch_target: true },
      assistant: { new_role: :assistant, switch_target: false },
      aunt_uncle: { new_role: :aunt_uncle, switch_target: false },
      bank_advisor: { new_role: :bank_advisor, switch_target: false },
      bank_advisor_client: { new_role: :bank_advisor, switch_target: true },
      boss: { new_role: :assistant, switch_target: true },
      bookkeeper: { new_role: :bookkeeper, switch_target: false },
      bookkeeper_mandate: { new_role: :bookkeeper, switch_target: true },
      brother_sister: { new_role: :sibling, switch_target: false },
      cousin_cousin: { new_role: :cousin, switch_target: false },
      daughter_son: { new_role: :parent, switch_target: true },
      debtor: { new_role: :creditor, switch_target: true },
      divorcee: { new_role: :divorcee, switch_target: false },
      employee: { new_role: :employee, switch_target: false },
      employer: { new_role: :employee, switch_target: true },
      estate_agent: { new_role: :real_estate_consultant, switch_target: false },
      estate_agent_mandate: { new_role: :real_estate_consultant, switch_target: true },
      father_mother: { new_role: :parent, switch_target: false },
      financial_auditor: { new_role: :financial_auditor, switch_target: false },
      financial_auditor_mandate: { new_role: :financial_auditor, switch_target: true },
      granddaughter_grandson: { new_role: :grandparent, switch_target: true },
      grandma_grandpa: { new_role: :grandparent, switch_target: false },
      hqt_consultant: { new_role: :hqt_consultant, switch_target: false },
      hqt_contact: { new_role: :hqt_consultant, switch_target: true },
      husband_wife: { new_role: :spouse, switch_target: false },
      insurance_broker: { new_role: :insurance_broker, switch_target: false },
      insurance_broker_client: { new_role: :insurance_broker, switch_target: true },
      landlord: { new_role: :landlord, switch_target: false },
      lawyer: { new_role: :lawyer, switch_target: false },
      lawyer_mandate: { new_role: :lawyer, switch_target: true },
      loaner: { new_role: :creditor, switch_target: false },
      mergers_acquisitions_advisor: { new_role: :mergers_acquisitions_advisor, switch_target: false },
      mergers_acquisitions_advisor_mandate: { new_role: :mergers_acquisitions_advisor, switch_target: false },
      nephew_niece: { new_role: :aunt_uncle, switch_target: true },
      notary: { new_role: :notary, switch_target: false },
      notary_mandate: { new_role: :notary, switch_target: true },
      private_equity_consultant: { new_role: :private_equity_consultant, switch_target: false },
      private_equity_consultant_mandate: { new_role: :private_equity_consultant, switch_target: true },
      real_estate_manager: { new_role: :real_estate_manager, switch_target: false },
      real_estate_manager_client: { new_role: :real_estate_manager, switch_target: true },
      real_estate_broker: { new_role: :real_estate_broker, switch_target: false },
      real_estate_broker_client: { new_role: :real_estate_broker, switch_target: true },
      renter: { new_role: :landlord, switch_target: true },
      tax_advisor: { new_role: :tax_advisor, switch_target: false },
      tax_mandate: { new_role: :tax_advisor, switch_target: true },
      wealth_manager: { new_role: :wealth_manager, switch_target: false },
      wealth_manager_client: { new_role: :wealth_manager, switch_target: true },
    }

    person_to_organization_mappings = {
      account_manager_asset_manager: { new_role: :account_manager_asset_manager, switch_target: false },
      administrative_board_member: { new_role: :governing_board_member, switch_target: false },
      advisor: { new_role: :advisor, switch_target: false },
      analyst: { new_role: :analyst, switch_target: false },
      assistant: { new_role: :assistant, switch_target: false },
      benefactor: { new_role: :benefactor, switch_target: false },
      beneficial_owner: { new_role: :economic_owner, switch_target: false },
      beneficiary: { new_role: :beneficial_owner, switch_target: false },
      bookkeeper: { new_role: :bookkeeper, switch_target: false },
      broker_insurance: { new_role: :insurance_broker, switch_target: false },
      broker_real_estate: { new_role: :real_estate_broker, switch_target: false },
      ceo: { new_role: :ceo, switch_target: false },
      cfo: { new_role: :cfo, switch_target: false },
      chairman: { new_role: :managing_board_member, switch_target: false },
      cio: { new_role: :cio, switch_target: false },
      client_bank: { new_role: :client_bank, switch_target: false },
      client_holding_company: { raise: true },
      client_insurance: { new_role: :insurance_broker, switch_target: false },
      client_wealth_management: { new_role: :client_wealth_management, switch_target: false },
      consultant: { new_role: :consultant, switch_target: false },
      consultant_bank: { new_role: :bank_consultant, switch_target: false },
      contact: { new_role: :contact, switch_target: false },
      contact_asset_manager: { new_role: :contact_asset_manager, switch_target: false },
      contact_contractor: { new_role: :contact_contractor, switch_target: false },
      contact_depot_bank: { new_role: :contact_depot_bank, switch_target: false },
      custodian_real_estate: { new_role: :custodian_real_estate, switch_target: false },
      customer_consultant: { new_role: :customer_consultant, switch_target: false },
      director: { new_role: :director, switch_target: false },
      employee: { new_role: :employee, switch_target: false },
      family_officer: { new_role: :family_officer, switch_target: false },
      general_partner: { new_role: :general_partner, switch_target: false },
      hqt_contact: { new_role: :hqt_consultant, switch_target: false },
      investment_manager: { new_role: :investment_manager, switch_target: false },
      limited_partner: { new_role: :limited_partner, switch_target: false },
      managing_director: { new_role: :managing_director, switch_target: false },
      managing_general_partner: { new_role: :managing_general_partner, switch_target: false },
      managing_partner: { new_role: :managing_partner, switch_target: false },
      mandate: { new_role: :mandate, switch_target: false },
      mandate_bookkeeper: { new_role: :bookkeeper, switch_target: false },
      mandate_financial_auditor: { new_role: :financial_auditor, switch_target: false },
      mandate_lawyer: { new_role: :lawyer, switch_target: false },
      mandate_mergers_acquisitions_advisor: { new_role: :mergers_acquisitions_advisor, switch_target: false },
      mandate_notary: { new_role: :notary, switch_target: false },
      mandate_tax_advisor: { new_role: :tax_advisor, switch_target: false },
      member_investment_committee: { new_role: :member_investment_committee, switch_target: false },
      partner: { new_role: :partner, switch_target: false },
      portfolio_manager: { new_role: :portfolio_manager, switch_target: false },
      portfolio_manager_alternative_investments: { new_role: :portfolio_manager_alternative_investments, switch_target: false },
      procurator: { new_role: :authorized_officer, switch_target: false },
      renter: { new_role: :renter, switch_target: false },
      shareholder: { new_role: :shareholder, switch_target: false },
      spokesperson_of_the_board: { new_role: :spokesperson_of_the_board, switch_target: false },
      supervisor: { raise: true },
    }

    organization_to_organization_mappings = {
      attorney: { new_role: :authorized_representative, switch_target: false },
      beneficial_owner: { new_role: :economic_owner, switch_target: false },
      bookkeeper: { new_role: :bookkeeper, switch_target: false },
      broker_insurance: { new_role: :insurance_broker, switch_target: false },
      broker_real_estate: { new_role: :real_estate_broker, switch_target: false },
      chairman: { raise: true },
      client_bank: { new_role: :bank, switch_target: true },
      client_holding_company: { new_role: :investment_company, switch_target: false },
      client_insurance: { new_role: :insurance_broker, switch_target: true },
      client_wealth_management: { new_role: :wealth_manager, switch_target: true },
      consultant: { new_role: :consultant, switch_target: false },
      consultant_bank: { new_role: :financial_investment_management_company, switch_target: false },
      contact: { new_role: :contact, switch_target: false },
      contact_depot_bank: { new_role: :depot_bank, switch_target: false },
      employee: { raise: true },
      investment_manager: { new_role: :investment, switch_target: false },
      managing_director: { new_role: :managing_director, switch_target: false },
      mandate: { raise: true },
      mandate_bookkeeper: { new_role: :bookkeeper, switch_target: true },
      mandate_tax_advisor: { new_role: :tax_advisor, switch_target: true },
      renter: { new_role: :landlord, switch_target: true },
      shareholder: { new_role: :shareholder, switch_target: false },
      tax_advisor: { new_role: :tax_advisor, switch_target: false },
      wealth_manager: { new_role: :wealth_manager, switch_target: false },
    }

    mandate_member_mappings = {
      bookkeeper: { new_role: :bookkeeper, switch_target: false },
      owner: { skip: true },
      auditor: { raise: true },
      investment: { raise: true },
      risk_manager: { raise: true },
      administrative_board_member: { new_role: :supervisory_board_member, switch_target: false },
      advisor: { new_role: :advisor, switch_target: false },
      assistance: { new_role: :assistant, switch_target: false },
      attorney: { new_role: :authorized_representative, switch_target: false },
      beneficial_owner: { new_role: :economic_owner, switch_target: false },
      beneficiary: { new_role: :beneficial_owner, switch_target: false },
      capital_management_company: { new_role: :financial_investment_management_company, switch_target: false },
      chairman: { new_role: :managing_board_member, switch_target: false },
      consultant: { new_role: :consultant, switch_target: false },
      contact_depot_bank: { new_role: :contact_depot_bank, switch_target: false },
      contact_fund: { new_role: :contact_asset_manager, switch_target: false },
      employee: { new_role: :employee, switch_target: false },
      family_officer: { new_role: :family_officer, switch_target: false },
      investment_manager: { new_role: :investment_manager, switch_target: false },
      lawyer: {
        p2p: { new_role: :lawyer, switch_target: false },
        p2o: { new_role: :lawyer, switch_target: false },
        o2p: { raise: true },
        o2o: { raise: true },
      },
      managing_director: { new_role: :managing_director, switch_target: false },
      notary: { new_role: :notary, switch_target: false },
      portfolio_manager: { new_role: :portfolio_manager, switch_target: false },
      procurator: { new_role: :authorized_officer, switch_target: false },
      shareholder: { new_role: :shareholder, switch_target: false },
      supervisory_board_member: { new_role: :governing_board_member, switch_target: false },
      tax_advisor: {
        p2p: { new_role: :tax_advisor, switch_target: false },
        p2o: { new_role: :tax_advisor, switch_target: false },
        o2p: { new_role: :mandate_tax_advisor, switch_target: true },
        o2o: { new_role: :tax_advisor, switch_target: false },
      },
      wealth_manager: { new_role: :wealth_manager, switch_target: false },
    }

    # Takes a contact and returns 'p' for Contact::Person or 'o' for Contact::Organization
    def type_char(contact)
      contact.type.split('::').last.chars.first.downcase
    end

    # Apply mapping defined above
    def create_relationship(source, target, original_mapping)
      relation_identifier = :"#{type_char(source)}2#{type_char(target)}"
      mapping = original_mapping[relation_identifier] || original_mapping
      raise ActiveRecord::ActiveRecordError if mapping.nil? || mapping[:raise]

      if ContactRelationship.find_by(
          source_contact: mapping[:switch_target] ? target : source,
          target_contact: mapping[:switch_target] ? source : target,
          role: mapping[:new_role]
        )
        @previous_relations[source.id] = @previous_relations[source.id].merge({
          duplicates_count: @previous_relations[source.id][:duplicates_count] + 1
        })
        @previous_relations[target.id] = @previous_relations[target.id].merge({
          duplicates_count: @previous_relations[target.id][:duplicates_count] + 1
        })
        @duplicates_count += 1
      else
        ContactRelationship.create!(
          source_contact: mapping[:switch_target] ? target : source,
          target_contact: mapping[:switch_target] ? source : target,
          role: mapping[:new_role]
        )
      end
    end

    ActiveRecord::Base.transaction do
      @previous_relations = {}
      @duplicates_count = 0

      # Remember current counts of inter_person_relationships and organization_members per contact
      Contact.find_in_batches do |batch|
        batch.each do |contact|
          @previous_relations[contact.id] = {
            inter_person_relationships_count: (
              contact.active_person_relationships.count + contact.passive_person_relationships.count
            ),
            organization_members_count: contact.organization_members.count,
            contact_members_count: contact.contact_members.count,
            duplicates_count: 0
          }
        end
      end

      # Create a new ContactRelationship for every InterPersonRelationship
      InterPersonRelationship.find_in_batches do |batch|
        batch.each do |inter_person_relationship|
          mapping = person_mappings[inter_person_relationship.role.to_sym]
          create_relationship(
            inter_person_relationship.source_person,
            inter_person_relationship.target_person,
            mapping
          )
        end
      end

      # Create a new ContactRelationship for every OrganizationMember
      OrganizationMember.find_in_batches do |batch|
        batch.each do |organization_member|
          source = organization_member.contact
          mappings = if source.type == 'Contact::Organization'
            puts 'organization_to_organization_mappings'
            organization_to_organization_mappings
          else
            puts 'person_to_organization_mappings'
            person_to_organization_mappings
          end

          mapping = mappings[organization_member.role.to_sym]
          puts organization_member.role.to_sym
          create_relationship(
            source,
            organization_member.organization,
            mapping
          )
        end
      end

      # Check if count of contact_relationships equals the count of the previously existing relationships
      @previous_relations.each do |contact_id, relations|
        contact = Contact.find(contact_id)
        if (
            contact.active_contact_relationships.count +
            contact.passive_contact_relationships.count +
            relations[:duplicates_count]
          ) != (
            relations[:inter_person_relationships_count] +
            relations[:organization_members_count] +
            relations[:contact_members_count]
          )
          puts contact_id
          puts "active_contact_relationships: #{contact.active_contact_relationships.count}"
          puts "passive_contact_relationships: #{contact.passive_contact_relationships.count}"
          puts "duplicates_count: #{relations[:duplicates_count]}"
          puts "inter_person_relationships_count: #{relations[:inter_person_relationships_count]}"
          puts "organization_members_count: #{relations[:organization_members_count]}"
          puts "contact_members_count: #{relations[:contact_members_count]}"
          raise ActiveRecord::ActiveRecordError
        end
      end

      previous_contact_relationship_count = ContactRelationship.count
      migrated_mandate_members_count = 0
      @duplicates_count = 0

      # Create a ContactRelationship per MandateMember that was not an `owner`
      Mandate.find_in_batches do |batch|
        batch.each do |mandate|
          owners = mandate.owners.map(&:contact)
          mandate.mandate_members.each do |mandate_member|
            puts mandate_member.read_attribute_before_type_cast('member_type').to_sym
            mapping = mandate_member_mappings[mandate_member.read_attribute_before_type_cast('member_type').to_sym]
            next if mapping[:skip]
            owners.each do |owner|
              create_relationship(
                mandate_member.contact,
                owner,
                mapping
              )
              migrated_mandate_members_count += 1
            end
            mandate_member.destroy!
          end
        end
      end

      # Check if count of contact_relationships has increased by the amount of deleted mandate_members
      puts "ContactRelationship.count: #{ContactRelationship.count}"
      puts "previous_contact_relationship_count: #{previous_contact_relationship_count}"
      puts "migrated_mandate_members_count: #{migrated_mandate_members_count}"
      puts "duplicates_count: #{@duplicates_count}"
      if ContactRelationship.count != (
          previous_contact_relationship_count + migrated_mandate_members_count - @duplicates_count
        )
        raise ActiveRecord::ActiveRecordError
      end
    end
  end
end
