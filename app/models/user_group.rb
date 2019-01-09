# frozen_string_literal: true

# == Schema Information
#
# Table name: user_groups
#
#  id         :uuid             not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  comment    :text
#  roles      :string           default([]), is an Array
#

# Defines the User Group
class UserGroup < ApplicationRecord
  has_and_belongs_to_many :mandate_groups, -> { distinct }
  has_and_belongs_to_many :users, -> { distinct }

  has_paper_trail(skip: SKIPPED_ATTRIBUTES)

  validates :name, presence: true
  validates :roles, role: true

  AVAILABLE_ROLES = %i[
    admin
    alternative_investments
    contacts_destroy
    contacts_export
    contacts_read
    contacts_write
    families_destroy
    families_export
    families_read
    families_write
    mandates_destroy
    mandates_export
    mandates_read
    mandates_write
    funds_destroy
    funds_export
    funds_read
    funds_write
  ].freeze

  scope :with_user_count, lambda {
    from(
      '(SELECT ug.*, uc.user_count FROM user_groups ug LEFT JOIN (SELECT ugu.user_group_id AS ' \
      'user_group_id, COUNT(*) AS user_count FROM user_groups_users ugu GROUP BY ugu.user_group_id) ' \
      'uc ON ug.id = uc.user_group_id) user_groups'
    )
  }
end
