# frozen_string_literal: true

# == Schema Information
#
# Table name: lists
#
#  aasm_state :string           default("active"), not null
#  comment    :text
#  created_at :datetime         not null
#  id         :uuid             not null, primary key
#  name       :string
#  updated_at :datetime         not null
#  user_id    :uuid             not null
#
# Indexes
#
#  index_lists_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

# Defines the List
class List < ApplicationRecord
  include AASM
  include RememberStateTransitions

  strip_attributes only: :name, collapse_spaces: true

  belongs_to :user

  has_many :items, class_name: 'List::Item', dependent: :destroy, inverse_of: :list
  has_many :contacts, source: :listable, source_type: 'Contact', through: :items
  has_many :mandates, source: :listable, source_type: 'Mandate', through: :items

  has_paper_trail(skip: SKIPPED_ATTRIBUTES)

  validates :user_id, presence: true
  validates :name, presence: true

  aasm do
    state :active, initial: true
    state :archived

    event :archive do
      transitions from: :active, to: :archived
    end

    event :unarchive do
      transitions from: :archived, to: :active
    end
  end

  alias_attribute :state, :aasm_state
end
