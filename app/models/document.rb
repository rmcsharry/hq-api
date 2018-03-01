# == Schema Information
#
# Table name: documents
#
#  id          :uuid             not null, primary key
#  name        :string           not null
#  category    :string           not null
#  valid_from  :date
#  valid_to    :date
#  uploader_id :uuid             not null
#  owner_type  :string           not null
#  owner_id    :uuid             not null
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

  CATEGORIES = %i[
    contract_hq contract_general invoice performance_report bank_reports commercial_register tax insurance
    legitimation warrant client_communication kyc bank_documents
  ].freeze

  belongs_to :uploader, class_name: 'User', inverse_of: :documents
  belongs_to :owner, polymorphic: true, inverse_of: :documents
  has_one_attached :file

  validates :name, presence: true
  validates :category, presence: true
  validate :valid_to_greater_or_equal_valid_from

  enumerize :category, in: CATEGORIES, scope: true

  private

  # Validates if valid_from is before or on the same date as valid_to if both are set
  # @return [void]
  def valid_to_greater_or_equal_valid_from
    return if valid_from.blank? || valid_to.blank? || valid_to >= valid_from
    errors.add(:valid_to, "can't be before valid_from")
  end
end
