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

# Defines the relationship model for contact to contact relationships
# rubocop:disable Metrics/ClassLength
class ContactRelationship < ApplicationRecord
  extend Enumerize

  belongs_to :target_contact, inverse_of: :passive_contact_relationships, class_name: 'Contact'
  belongs_to :source_contact, inverse_of: :active_contact_relationships, class_name: 'Contact'

  scope :indirectly_associating_mandates_to_contact_with_id, lambda { |contact_id|
    joins('LEFT JOIN contacts c ON c.id = contact_relationships.source_contact_id OR ' \
          'c.id = contact_relationships.target_contact_id')
      .joins('LEFT JOIN mandate_members mm ON mm.contact_id = c.id')
      .joins('LEFT JOIN mandates m ON m.id = mm.mandate_id')
      .where('contact_relationships.source_contact_id = ? OR ' \
             'contact_relationships.target_contact_id = ?', contact_id, contact_id)
      .where('mm.member_type': :owner)
      .where.not('mm.contact_id': contact_id)
  }

  has_paper_trail(
    meta: {
      parent_item_id: :source_contact_id,
      parent_item_type: 'Contact'
    },
    skip: SKIPPED_ATTRIBUTES
  )

  PERSON_TO_PERSON_ROLES = [
    # HQT roles
    %i[
      hqt_consultant
      recommendation
    ],
    # Contact
    %i[
      contact_asset_manager
      contact_contractor
      contact_depot_bank
    ],
    # Professional relationships
    %i[
      architect
      assistant
      authorized_representative
      bank_advisor
      bookkeeper
      creditor
      employee
      family_officer
      financial_auditor
      insurance_broker
      landlord
      lawyer
      mergers_acquisitions_advisor
      notary
      private_equity_consultant
      real_estate_broker
      real_estate_consultant
      real_estate_manager
      tax_advisor
      wealth_manager
    ],
    # Family and friends relationships
    %i[
      acquaintance
      aunt_uncle
      cousin
      divorcee
      grandparent
      parent
      sibling
      spouse
    ]
  ].flatten.freeze

  PERSON_TO_ORGANIZATION_ROLES = [
    # HQT roles
    %i[
      hqt_consultant
      recommendation
    ],
    # owner
    %i[
      benefactor
      beneficial_owner
      economic_owner
      general_partner
      limited_partner
      managing_general_partner
      managing_partner
      shareholder
    ],
    # management
    %i[
      authorized_officer
      ceo
      cfo
      cio
      director
      governing_board_member
      managing_board_member
      managing_director
      supervisory_board_member
    ],
    # employees
    %i[
      advisor
      analyst
      asset_manager
      assistant
      bank_consultant
      bookkeeper
      consultant
      customer_consultant
      employee
      family_officer
      investment_manager
      member_investment_committee
      portfolio_manager
      portfolio_manager_alternative_investments
      spokesperson_of_the_board
    ],
    # contacts
    %i[
      contact
      contact_asset_manager
      contact_contractor
      contact_depot_bank
    ],
    # professional relationships
    %i[
      account_manager_asset_manager
      authorized_representative
      client_bank
      client_wealth_management
      custodian_real_estate
      financial_auditor
      insurance_broker
      lawyer
      mandate
      mandate_tax_advisor
      mergers_acquisitions_advisor
      notary
      partner
      real_estate_broker
      renter
      tax_advisor
    ]
  ].flatten.freeze

  ORGANIZATION_TO_ORGANIZATION_ROLES = [
    # owner
    %i[
      beneficial_owner
      custodian
      economic_owner
      fictitious_beneficial_owner
      general_partner
      investment
      limited_partner
      managing_director
      managing_general_partner
      managing_partner
      shareholder
    ],
    # contractor
    %i[
      bank
      bookkeeper
      consultant
      contact
      depot_bank
      financial_investment_management_company
      insurance_broker
      investment_company
      landlord
      real_estate_broker
      tax_advisor
      wealth_manager
    ]
  ].flatten.freeze

  validates :role,
            presence: true,
            uniqueness: {
              scope: %i[source_contact_id target_contact_id]
            }
  validate :role_inclusion

  enumerize :role,
            in: [
              *ORGANIZATION_TO_ORGANIZATION_ROLES,
              *PERSON_TO_ORGANIZATION_ROLES,
              *PERSON_TO_PERSON_ROLES
            ],
            scope: true

  private

  # Validates if role is suitable for the given relationship configuration that is one of:
  # person-person, person-organization, or organization-organization
  # @return [void]
  def role_inclusion
    return if permitted_roles.include?(role&.to_sym)

    errors.add(
      :role,
      "`#{role}` is an invalid role for #{source_contact&.type}->#{target_contact&.type} relationships"
    )
  end

  def permitted_roles
    source_is_person = source_contact.is_a?(Contact::Person)
    target_is_person = target_contact.is_a?(Contact::Person)

    return PERSON_TO_PERSON_ROLES if source_is_person && target_is_person

    return ORGANIZATION_TO_ORGANIZATION_ROLES if !source_is_person && !target_is_person

    return PERSON_TO_ORGANIZATION_ROLES if source_is_person

    []
  end
end
# rubocop:enable Metrics/ClassLength
