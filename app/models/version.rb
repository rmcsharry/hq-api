# frozen_string_literal: true

# == Schema Information
#
# Table name: versions
#
#  created_at       :datetime
#  event            :string           not null
#  id               :uuid             not null, primary key
#  item_id          :uuid             not null
#  item_type        :string           not null
#  object           :jsonb
#  object_changes   :jsonb
#  parent_item_id   :uuid
#  parent_item_type :string
#  whodunnit        :uuid
#
# Indexes
#
#  index_versions_on_item_type_and_item_id  (item_type,item_id)
#

# Defines the Version
class Version < PaperTrail::Version
  belongs_to :user, foreign_key: 'whodunnit', inverse_of: :created_versions
  belongs_to :parent_item, polymorphic: true, inverse_of: :child_versions

  alias_attribute :changes, :changeset
end
