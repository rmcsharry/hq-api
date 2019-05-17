# frozen_string_literal: true

# == Schema Information
#
# Table name: contact_details
#
#  category   :string
#  contact_id :uuid
#  created_at :datetime         not null
#  id         :uuid             not null, primary key
#  primary    :boolean          default(FALSE), not null
#  type       :string
#  updated_at :datetime         not null
#  value      :string
#
# Indexes
#
#  index_contact_details_on_contact_id  (contact_id)
#
# Foreign Keys
#
#  fk_rails_...  (contact_id => contacts.id)
#

# Defines the Contact Details of a Contact
class ContactDetail < ApplicationRecord
  extend Enumerize

  CATEGORIES = %i[home work vacation].freeze

  belongs_to :contact

  has_paper_trail(
    meta: {
      parent_item_id: :contact_id,
      parent_item_type: 'Contact'
    },
    skip: SKIPPED_ATTRIBUTES
  )

  validates :type, presence: true
  validates :category, presence: true
  validates :value, presence: true

  enumerize :category, in: CATEGORIES, scope: true

  alias_attribute :contact_detail_type, :type

  after_save :remove_primary_from_others, if: :primary

  def to_s
    value
  end

  private

  def remove_primary_from_others
    # rubocop:disable Rails/SkipsModelValidations
    ContactDetail.where(contact: contact, type: type).where.not(id: id).update_all(primary: false)
    # rubocop:enable Rails/SkipsModelValidations
  end
end
