# frozen_string_literal: true

# == Schema Information
#
# Table name: list_items
#
#  comment       :text
#  created_at    :datetime         not null
#  id            :uuid             not null, primary key
#  list_id       :uuid             not null
#  listable_id   :uuid             not null
#  listable_type :string           not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_list_items_on_list_id                        (list_id)
#  index_list_items_on_listable_type_and_listable_id  (listable_type,listable_id)
#
# Foreign Keys
#
#  fk_rails_...  (list_id => lists.id)
#

class List
  # Defines the List::Item
  class Item < ApplicationRecord
    LISTABLE_TYPES = %w[
      Contact
      Mandate
    ].freeze

    belongs_to :list, inverse_of: :items
    belongs_to :listable, inverse_of: :list_items, polymorphic: true

    validates :list, presence: true
    validates :listable_id, presence: true, uniqueness: { case_sensitive: false, scope: %i[list_id listable_type] }
    validates :listable_type, inclusion: { in: LISTABLE_TYPES }, presence: true
  end
end
