# frozen_string_literal: true

# == Schema Information
#
# Table name: versions
#
#  id               :uuid             not null, primary key
#  item_type        :string           not null
#  item_id          :uuid             not null
#  event            :string           not null
#  whodunnit        :uuid
#  object           :jsonb
#  object_changes   :jsonb
#  parent_item_type :string
#  parent_item_id   :uuid
#  created_at       :datetime
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
