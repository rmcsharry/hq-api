# frozen_string_literal: true

# == Schema Information
#
# Table name: documents
#
#  aasm_state  :string           default("created"), not null
#  category    :string           not null
#  created_at  :datetime         not null
#  id          :uuid             not null, primary key
#  name        :string           not null
#  owner_id    :uuid
#  owner_type  :string
#  type        :string
#  updated_at  :datetime         not null
#  uploader_id :uuid             not null
#  valid_from  :date
#  valid_to    :date
#
# Indexes
#
#  index_documents_on_owner_type_and_owner_id  (owner_type,owner_id)
#  index_documents_on_uploader_id              (uploader_id)
#
# Foreign Keys
#
#  fk_rails_...  (uploader_id => users.id)
#

# Defines the Document model
class Document < ApplicationRecord
  extend Enumerize
  include AASM
  include Lockable
  include RememberStateTransitions

  CATEGORIES = %i[
    bank_documents
    bank_feeder
    bank_reports
    client_communication
    commercial_register
    commercial_register_feeder
    contract_general
    contract_hq
    contracts_feeder
    financial_statement
    insurance
    invoice
    kyc
    legitimation
    performance_report
    registration
    signature_feeder
    tax
    tax_general
    tax_declaration
    warrant
  ].freeze

  belongs_to :uploader, class_name: 'User', inverse_of: :documents
  belongs_to :owner, polymorphic: true, inverse_of: :documents
  has_many :reminders, class_name: 'Task', as: :subject, inverse_of: :subject, dependent: :destroy
  has_one_attached :file

  has_paper_trail(skip: SKIPPED_ATTRIBUTES)

  aasm do
    state :created, initial: true
    state :archived

    event :archive do
      transitions from: %i[created archived], to: :archived
    end

    event :unarchive do
      transitions from: %i[created archived], to: :created
    end
  end

  validates :name, presence: true
  validates :category, presence: true
  validate :valid_to_greater_or_equal_valid_from

  enumerize :category, in: CATEGORIES, scope: true

  alias_attribute :document_type, :type
  alias_attribute :state, :aasm_state

  def unlocked_attributes
    %w[aasm_state updated_at]
  end

  private

  # Validates if valid_from is before or on the same date as valid_to if both are set
  # @return [void]
  def valid_to_greater_or_equal_valid_from
    return if valid_from.blank? || valid_to.blank? || valid_to >= valid_from

    errors.add(:valid_to, "can't be before valid_from")
  end
end
