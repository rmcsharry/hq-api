# == Schema Information
#
# Table name: mandate_members
#
#  id          :uuid             not null, primary key
#  member_type :string
#  start_date  :date
#  end_date    :date
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  contact_id  :uuid
#  mandate_id  :uuid
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
    owner tax_advisor beneficiary wealth_manager lawyer notary family_officer bookkeeper contact_depot_bank
    contact_fund advisor chairman administrative_board_member supervisory_board_member auditor managing_director
  ].freeze

  belongs_to :mandate
  belongs_to :contact

  validates :member_type, presence: true
  validates(
    :contact_id,
    uniqueness: { scope: :mandate_id, message: 'should occur only once per mandate', case_sensitive: false }
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
