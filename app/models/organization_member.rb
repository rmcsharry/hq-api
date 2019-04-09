# frozen_string_literal: true

# == Schema Information
#
# Table name: organization_members
#
#  id              :uuid             not null, primary key
#  role            :string           not null
#  organization_id :uuid             not null
#  contact_id      :uuid             not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_organization_members_on_contact_id       (contact_id)
#  index_organization_members_on_organization_id  (organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => contacts.id)
#

# Defines the Organization Member
class OrganizationMember < ApplicationRecord
  extend Enumerize

  belongs_to :organization, class_name: 'Contact::Organization', inverse_of: :contact_members
  belongs_to :contact, inverse_of: :organization_members

  has_paper_trail(
    meta: {
      parent_item_id: :contact_id,
      parent_item_type: 'Contact'
    },
    skip: SKIPPED_ATTRIBUTES
  )

  AVAILABLE_ROLES = %i[
    account_manager_asset_manager
    administrative_board_member
    advisor
    analyst
    assistant
    benefactor
    beneficial_owner
    beneficiary
    bookkeeper
    broker_insurance
    broker_real_estate
    ceo
    cfo
    chairman
    cio
    client_bank
    client_holding_company
    client_insurance
    client_wealth_management
    consultant
    consultant_bank
    contact
    contact_asset_manager
    contact_contractor
    contact_depot_bank
    custodian_real_estate
    customer_consultant
    director
    employee
    family_officer
    general_partner
    hqt_contact
    investment_manager
    limited_partner
    managing_director
    managing_general_partner
    managing_partner
    mandate
    mandate_bookkeeper
    mandate_financial_auditor
    mandate_lawyer
    mandate_mergers_acquisitions_advisor
    mandate_notary
    mandate_tax_advisor
    member_investment_committee
    partner
    portfolio_manager
    portfolio_manager_alternative_investments
    procurator
    renter
    shareholder
    spokesperson_of_the_board
    supervisor
  ].freeze

  enumerize :role, in: AVAILABLE_ROLES, scope: true
  validates :role, presence: true
end
