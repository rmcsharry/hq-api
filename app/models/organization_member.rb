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
  belongs_to :organization, class_name: 'Contact::Organization', inverse_of: :contact_members
  belongs_to :contact, inverse_of: :organization_members

  has_paper_trail(
    meta: {
      parent_item_id: :contact_id,
      parent_item_type: 'Contact'
    },
    skip: SKIPPED_ATTRIBUTES
  )

  validates :role, presence: true
end
