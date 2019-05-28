# frozen_string_literal: true

# == Schema Information
#
# Table name: mandate_members
#
#  comment     :text
#  contact_id  :uuid
#  created_at  :datetime         not null
#  id          :uuid             not null, primary key
#  mandate_id  :uuid
#  member_type :string
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

  NON_UNIQUE_MEMBER_TYPES = %i[
    owner
  ].freeze

  UNIQUE_MEMBER_TYPES = %i[
    assistant
    bookkeeper
    primary_consultant
    secondary_consultant
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

  validates(
    :contact_id,
    uniqueness: {
      case_sensitive: false,
      message: 'should occur only once per mandate and member type',
      scope: %i[mandate_id member_type]
    }
  )
  validates(
    :member_type,
    presence: true,
    uniqueness: {
      if: proc do |mandate_member|
        UNIQUE_MEMBER_TYPES.include?(mandate_member.member_type&.to_sym)
      end,
      message: 'should occur only once per mandate',
      scope: :mandate_id
    }
  )

  enumerize :member_type, in: NON_UNIQUE_MEMBER_TYPES + UNIQUE_MEMBER_TYPES, scope: true
end
