# frozen_string_literal: true

# == Schema Information
#
# Table name: mandate_groups
#
#  id         :uuid             not null, primary key
#  name       :string
#  group_type :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# Defines the Mandate Group
class MandateGroup < ApplicationRecord
  extend Enumerize

  GROUP_TYPES = %i[family organization].freeze

  has_and_belongs_to_many :mandates
  has_and_belongs_to_many :user_groups

  validates :name, presence: true
  validates :group_type, presence: true

  enumerize :group_type, in: GROUP_TYPES, scope: true

  scope :families, -> { where(group_type: 'family') }
  scope :organizations, -> { where(group_type: 'organization') }

  scope :with_mandate_count, lambda {
    from(
      '(SELECT mg.*, mgc.mandate_count FROM mandate_groups mg LEFT JOIN (SELECT mgm.mandate_group_id AS ' \
      'mandate_group_id, COUNT(*) AS mandate_count FROM mandate_groups_mandates mgm GROUP BY mgm.mandate_group_id) ' \
      'mgc ON mg.id = mgc.mandate_group_id) mandate_groups'
    )
  }
end
