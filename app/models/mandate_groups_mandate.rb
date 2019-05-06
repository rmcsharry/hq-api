# frozen_string_literal: true

# == Schema Information
#
# Table name: mandate_groups_mandates
#
#  mandate_id       :uuid
#  mandate_group_id :uuid
#
# Indexes
#
#  by_mandate_group_and_mandate                       (mandate_group_id,mandate_id) UNIQUE
#  index_mandate_groups_mandates_on_mandate_group_id  (mandate_group_id)
#  index_mandate_groups_mandates_on_mandate_id        (mandate_id)
#
# Foreign Keys
#
#  fk_rails_...  (mandate_group_id => mandate_groups.id)
#  fk_rails_...  (mandate_id => mandates.id)
#

# Defines the Mandate Groups Mandate (join-table)
class MandateGroupsMandate < ApplicationRecord
  has_many :mandate_groups, dependent: :nullify
  has_many :mandates, dependent: :nullify

  has_paper_trail(
    meta: {
      parent_item_id: :mandate_group_id,
      parent_item_type: 'MandateGroup'
    },
    skip: SKIPPED_ATTRIBUTES
  )
end
