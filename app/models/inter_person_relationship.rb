# frozen_string_literal: true

# == Schema Information
#
# Table name: inter_person_relationships
#
#  id               :uuid             not null, primary key
#  role             :string           not null
#  target_person_id :uuid             not null
#  source_person_id :uuid             not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_inter_person_relationships_on_source_person_id  (source_person_id)
#  index_inter_person_relationships_on_target_person_id  (target_person_id)
#
# Foreign Keys
#
#  fk_rails_...  (source_person_id => contacts.id)
#  fk_rails_...  (target_person_id => contacts.id)
#

# Defines the inter-person relationships
class InterPersonRelationship < ApplicationRecord
  extend Enumerize

  belongs_to :target_person, class_name: 'Contact::Person', inverse_of: :passive_person_relationships
  belongs_to :source_person, class_name: 'Contact::Person', inverse_of: :active_person_relationships

  has_paper_trail(
    meta: {
      parent_item_id: :source_person_id,
      parent_item_type: 'Contact'
    },
    skip: SKIPPED_ATTRIBUTES
  )

  AVAILABLE_ROLES = %i[
    acquaintance
    architect
    architect_client
    assistant
    aunt_uncle
    bank_advisor
    bank_advisor_client
    boss
    bookkeeper
    bookkeeper_mandate
    brother_sister
    cousin_cousin
    daughter_son
    debtor
    divorcee
    employee
    employer
    estate_agent
    estate_agent_mandate
    father_mother
    financial_auditor
    financial_auditor_mandate
    granddaughter_grandson
    grandma_grandpa
    hqt_consultant
    hqt_contact
    husband_wife
    insurance_broker
    insurance_broker_client
    landlord
    lawyer
    lawyer_mandate
    loaner
    mergers_acquisitions_advisor
    mergers_acquisitions_advisor_mandate
    nephew_niece
    notary
    notary_mandate
    private_equity_consultant
    private_equity_consultant_mandate
    real_estate_manager
    real_estate_manager_client
    real_estate_broker
    real_estate_broker_client
    renter
    tax_advisor
    tax_mandate
    wealth_manager
    wealth_manager_client
  ].freeze

  validates :role, presence: true

  enumerize :role, in: AVAILABLE_ROLES, scope: true
end
