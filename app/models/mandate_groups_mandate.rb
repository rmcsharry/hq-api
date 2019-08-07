# frozen_string_literal: true

# == Schema Information
#
# Table name: mandate_groups_mandates
#
#  mandate_group_id :uuid             primary key
#  mandate_id       :uuid             primary key
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
  self.primary_keys = :mandate_group_id, :mandate_id

  belongs_to :mandate_group
  belongs_to :mandate

  def id
    mandate_id
  end

  has_paper_trail(
    meta: {
      parent_item_id: :mandate_group_id,
      parent_item_type: 'MandateGroup'
    },
    skip: SKIPPED_ATTRIBUTES
  )
end
