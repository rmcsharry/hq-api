# frozen_string_literal: true

# == Schema Information
#
# Table name: mandates
#
#  aasm_state                       :string
#  category                         :string
#  comment                          :text
#  confidential                     :boolean          default(FALSE), not null
#  created_at                       :datetime         not null
#  current_state_transition_id      :uuid
#  data_integrity_missing_fields    :string           default([]), is an Array
#  data_integrity_partial_score     :decimal(5, 4)    default(0.0)
#  data_integrity_score             :decimal(5, 4)    default(0.0)
#  datev_creditor_id                :string
#  datev_debitor_id                 :string
#  default_currency                 :string
#  id                               :uuid             not null, primary key
#  import_id                        :integer
#  mandate_number                   :string
#  previous_state_transition_id     :uuid
#  prospect_assets_under_management :decimal(20, 10)
#  prospect_fees_fixed_amount       :decimal(20, 10)
#  prospect_fees_min_amount         :decimal(20, 10)
#  prospect_fees_percentage         :decimal(20, 10)
#  psplus_id                        :string
#  psplus_pe_id                     :string
#  updated_at                       :datetime         not null
#  valid_from                       :date
#  valid_to                         :date
#
# Indexes
#
#  index_mandates_on_current_state_transition_id   (current_state_transition_id)
#  index_mandates_on_previous_state_transition_id  (previous_state_transition_id)
#
# Foreign Keys
#
#  fk_rails_...  (current_state_transition_id => state_transitions.id)
#  fk_rails_...  (previous_state_transition_id => state_transitions.id)
#  index_mandates_on_data_integrity_score  (data_integrity_score)
#

# Defines the Mandate model
# rubocop:disable Metrics/ClassLength
class Mandate < ApplicationRecord
  extend Enumerize
  include AASM
  include RememberStateTransitions
  include MandateWeight
  include WeightRulesMandate
  include IntegrityScorer

  strip_attributes only: %i[
    datev_creditor_id datev_debitor_id mandate_number psplus_id psplus_pe_id
  ], collapse_spaces: true

  CURRENCIES = Money::Currency.map(&:iso_code)
  CATEGORIES = %i[
    family_office_with_investment_advice family_office_without_investment_advice wealth_management investment_advice
    alternative_investments institutional reporting other
  ].freeze

  # rubocop:disable Rails/InverseOf
  has_one :assistant_mandate_member,
          -> { where(member_type: :assistant) },
          class_name: 'MandateMember'
  has_one :bookkeeper_mandate_member,
          -> { where(member_type: :bookkeeper) },
          class_name: 'MandateMember'
  has_one :primary_consultant_mandate_member,
          -> { where(member_type: :primary_consultant) },
          class_name: 'MandateMember'
  has_one :secondary_consultant_mandate_member,
          -> { where(member_type: :secondary_consultant) },
          class_name: 'MandateMember'

  belongs_to :current_state_transition,
             class_name: 'StateTransition',
             optional: true,
             autosave: true
  belongs_to :previous_state_transition,
             class_name: 'StateTransition',
             optional: true,
             autosave: true
  # rubocop:enable Rails/InverseOf

  has_one :assistant, through: :assistant_mandate_member, source: :contact
  has_one :bookkeeper, through: :bookkeeper_mandate_member, source: :contact
  has_one :primary_consultant, through: :primary_consultant_mandate_member, source: :contact
  has_one :secondary_consultant, through: :secondary_consultant_mandate_member, source: :contact

  has_many :bank_accounts, as: :owner, inverse_of: :owner, dependent: :destroy
  has_many :reminders, class_name: 'Task', as: :subject, inverse_of: :subject, dependent: :destroy
  has_many :child_versions, class_name: 'Version', as: :parent_item # rubocop:disable Rails/HasManyOrHasOneDependent
  has_many :contacts, through: :mandate_members
  has_many :documents, as: :owner, inverse_of: :owner, dependent: :destroy
  has_many :mandate_members, dependent: :destroy
  has_many :owners, -> { where(member_type: 'owner') }, class_name: 'MandateMember', inverse_of: :mandate
  has_many :investments, class_name: 'Investor', dependent: :destroy
  has_many :task_links, class_name: 'Task', as: :linked_object, inverse_of: :linked_object, dependent: :destroy
  has_many :list_items, as: :listable, class_name: 'List::Item', dependent: :destroy, inverse_of: :listable
  has_many :lists, through: :list_items
  has_and_belongs_to_many :activities, -> { distinct }
  has_and_belongs_to_many :mandate_groups, -> { distinct }
  has_and_belongs_to_many(
    :mandate_groups_families,
    -> { where(group_type: 'family') },
    class_name: 'MandateGroup'
  )
  has_and_belongs_to_many(
    :mandate_groups_organizations,
    -> { where(group_type: 'organization') },
    class_name: 'MandateGroup'
  )

  has_paper_trail(
    meta: {
      parent_item_id: :id,
      parent_item_type: 'Mandate'
    },
    skip: SKIPPED_ATTRIBUTES
  )

  # rubocop:disable Metrics/BlockLength
  aasm do
    after_all_transitions :remember_state_transition

    state :prospect_not_qualified, initial: true
    state :prospect_cold,
          :prospect_warm,
          :prospect_investment_proposal_created,
          :prospect_contract_draft_created,
          :prospect_contract_draft_approved,
          :prospect_contract_signed,
          :prospect_contract_countersigned,
          :prospect_contract_approved,
          :client,
          :cancelled

    # Possible next states

    event :become_prospect_cold do
      transitions from: %i[prospect_not_qualified], to: :prospect_cold
    end

    event :become_prospect_warm do
      transitions from: %i[prospect_not_qualified prospect_cold], to: :prospect_warm
    end

    event :become_prospect_investment_proposal_created do
      transitions from: %i[prospect_cold prospect_warm], to: :prospect_investment_proposal_created
    end

    event :become_prospect_contract_draft_created do
      transitions from: %i[prospect_investment_proposal_created], to: :prospect_contract_draft_created
    end

    event :become_prospect_contract_draft_approved do
      transitions from: %i[prospect_contract_draft_created], to: :prospect_contract_draft_approved
    end

    event :become_prospect_contract_signed do
      transitions from: %i[prospect_contract_draft_approved], to: :prospect_contract_signed
    end

    event :become_prospect_contract_countersigned do
      transitions from: %i[prospect_contract_signed], to: :prospect_contract_countersigned
    end

    event :become_prospect_contract_approved do
      transitions from: %i[prospect_contract_countersigned], to: :prospect_contract_approved
    end

    event :become_client, if: :primary_and_secondary_consultant_present? do
      transitions from: %i[prospect_contract_approved], to: :client
    end

    event :become_cancelled do
      transitions from: %i[client], to: :cancelled
    end

    # Possible previous states

    event :degrade_to_prospect_not_qualified do
      transitions from: %i[prospect_cold prospect_warm], to: :prospect_not_qualified
    end

    event :degrade_to_prospect_cold do
      transitions from: %i[prospect_warm], to: :prospect_cold
    end

    event :degrade_to_prospect_contract_draft_created do
      transitions from: %i[
        prospect_contract_draft_approved
        prospect_contract_signed
        prospect_contract_countersigned
        prospect_contract_approved
        client
      ], to: :prospect_contract_draft_created
    end

    event :degrade_to_client do
      transitions from: %i[cancelled], to: :client
    end
  end
  # rubocop:enable Metrics/BlockLength

  scope :with_owner_name, lambda {
    from(
      <<-SQL.squish
        (
          SELECT m.*, agg.name AS owner_name FROM mandates m LEFT JOIN (
            SELECT mm.mandate_id AS mandate_id,
              STRING_AGG(
                COALESCE(c.last_name || ', ' || c.first_name, c.organization_name), ', '
                ORDER BY c.last_name, c.first_name, c.organization_name
              ) AS name
            FROM mandate_members mm LEFT JOIN contacts c ON mm.contact_id = c.id
            WHERE mm.member_type = 'owner'
            GROUP BY mm.mandate_id
          ) agg ON m.id = agg.mandate_id
        ) mandates
      SQL
    )
  }

  scope :associated_to_contact_with_id, lambda { |contact_id|
    joins('LEFT JOIN mandate_members mm ON mandates.id = mm.mandate_id')
      .where('mm.contact_id': contact_id)
      .where('mm.member_type': %i[assistant bookkeeper primary_consultant secondary_consultant])
  }

  validates :category, presence: true
  validates :mandate_groups_organizations, presence: true
  validates :psplus_id, length: { maximum: 15 }
  validates :psplus_pe_id, length: { maximum: 15 }
  validates :data_integrity_score, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
  validates :data_integrity_partial_score, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
  validates :default_currency, presence: true, if: :default_currency_required?
  validate :valid_to_greater_or_equal_valid_from
  validate :presence_of_primary_consultant, if: :client?
  validate :presence_of_current_state_transition, if: :previous_state_transition?

  enumerize :category, in: CATEGORIES, scope: true
  enumerize :default_currency, in: CURRENCIES

  alias_attribute :state, :aasm_state

  def task_assignees
    assigned_contact_ids = mandate_members
                           .where(member_type: %i[assistant primary_consultant secondary_consultant])
                           .pluck(:contact_id)
    User.where(contact_id: assigned_contact_ids)
  end

  def current_state_completed_tasks_count
    tasks_associated_with_current_state.where(state: :finished).count
  end

  def current_state_total_tasks_count
    tasks_associated_with_current_state.count
  end

  private

  # Tasks that have been created when or after the current state transition happened
  # @return [ActiveRecord::Relation<Task>]
  def tasks_associated_with_current_state
    return reminders if current_state_transition.nil?

    reminders.where('created_at >= ?', current_state_transition.created_at)
  end

  # After integrity scoring calculation runs, assign the newly calculated scores
  def assign_score
    self.data_integrity_partial_score = @integrity_score
    self.data_integrity_score = factor_owners_into_score
  end

  def factor_owners_into_score
    # if no owners, then halve the score, else divide by the number of owners (+1 for the mandate itself)
    count = owners.count # NOTE: don't move this to the ternary below or you will get two DB reads
    @integrity_score + owners.sum { |owner| owner.contact.data_integrity_score } / (count.zero? ? 2 : count + 1)
  end

  # Validates if primary_consultant is present
  # @return [void]
  def presence_of_primary_consultant
    return if primary_consultant.present?

    errors.add(:mandate_members, 'have to contain a primary_consultant')
  end

  # Validates if current_state_transition is present
  # @return [void]
  def presence_of_current_state_transition
    return if current_state_transition.present?

    errors.add(:current_state_transition, 'must exist')
  end

  # Returns whether or not a previous state transition is present
  # @return [boolean]
  def previous_state_transition?
    previous_state_transition_id.present?
  end

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

  def default_currency_required?
    prospect_assets_under_management.present? ||
      prospect_fees_fixed_amount.present? ||
      prospect_fees_min_amount.present?
  end
end
# rubocop:enable Metrics/ClassLength
