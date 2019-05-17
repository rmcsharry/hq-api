# frozen_string_literal: true

# == Schema Information
#
# Table name: mandate_members
#
#  contact_id  :uuid
#  created_at  :datetime         not null
#  end_date    :date
#  id          :uuid             not null, primary key
#  mandate_id  :uuid
#  member_type :string
#  start_date  :date
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_mandate_members_on_contact_id  (contact_id)
#  index_mandate_members_on_mandate_id  (mandate_id)
#
# Foreign Keys
#
#  fk_rails_...  (contact_id => contacts.id)
#  fk_rails_...  (mandate_id => mandates.id)
#

# Defines the Mandate Member
class MandateMember < ApplicationRecord
  extend Enumerize

  MEMBER_TYPES = %i[
    administrative_board_member
    advisor
    assistance
    attorney
    auditor
    beneficial_owner
    beneficiary
    bookkeeper
    capital_management_company
    chairman
    consultant
    contact_depot_bank
    contact_fund
    employee
    family_officer
    investment
    investment_manager
    lawyer
    managing_director
    notary
    owner
    portfolio_manager
    procurator
    risk_manager
    shareholder
    supervisory_board_member
    tax_advisor
    wealth_manager
  ].freeze

  belongs_to :mandate
  belongs_to :contact

  has_paper_trail(
    meta: {
      parent_item_id: :mandate_id,
      parent_item_type: 'Mandate'
    },
    skip: SKIPPED_ATTRIBUTES
  )

  validates :member_type, presence: true
  validates(
    :contact_id,
    uniqueness: { scope: %i[mandate_id member_type],
                  message: 'should occur only once per mandate and member type', case_sensitive: false }
  )

  validate :end_date_greater_or_equal_start_date

  enumerize :member_type, in: MEMBER_TYPES, scope: true

  private

  # Validates if start_date is before or on the same date as end_date if both are set
  # @return [void]
  def end_date_greater_or_equal_start_date
    return if start_date.blank? || end_date.blank? || end_date >= start_date

    errors.add(:end_date, "can't be before start_date")
  end
end
