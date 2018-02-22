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

# Defines the Mandate model
class Mandate < ApplicationRecord
  extend Enumerize
  include AASM

  belongs_to :primary_consultant, class_name: 'Contact', optional: true, inverse_of: :primary_consultant_mandates
  belongs_to(
    :secondary_consultant, class_name: 'Contact', optional: true, inverse_of: :secondary_consultant_mandates
  )
  belongs_to :assistant, class_name: 'Contact', optional: true, inverse_of: :assistant_mandates
  belongs_to :bookkeeper, class_name: 'Contact', optional: true, inverse_of: :bookkeeper_mandates
  has_many :mandate_members, dependent: :destroy
  has_many :contacts, through: :mandate_members

  aasm do
    state :prospect, initial: true
    state :client, :cancelled

    event :become_client, if: :primary_and_secondary_consultant_present? do
      transitions from: %i[prospect cancelled], to: :client
    end

    event :cancel do
      transitions from: %i[prospect client], to: :cancelled
    end

    event :become_prospect do
      transitions from: %i[client cancelled], to: :prospect
    end
  end

  validates :category, presence: true
  validates :primary_consultant, presence: true, if: :client?
  validates :secondary_consultant, presence: true, if: :client?
  validate :valid_to_greater_or_equal_valid_from

  enumerize(
    :category,
    in: %i[
      family_office_with_investment_advice family_office_without_investment_advice wealth_management investment_advice
      alternative_investments institutional reporting
    ]
  )

  # Validates if valid_from date is before or on the same date as valid_to if both are set
  # @return [void]
  def valid_to_greater_or_equal_valid_from
    return if valid_to.blank? || valid_from.blank? || valid_to >= valid_from
    errors.add(:valid_to, "can't be before valid_from")
  end

  # Checks if primary and secondary consultant are present
  # @return [Boolean]
  def primary_and_secondary_consultant_present?
    primary_consultant.present? && secondary_consultant.present?
  end
end
