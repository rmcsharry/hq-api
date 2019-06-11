# frozen_string_literal: true

# == Schema Information
#
# Table name: activities
#
#  created_at  :datetime         not null
#  creator_id  :uuid
#  description :text
#  ended_at    :datetime
#  ews_id      :string
#  id          :uuid             not null, primary key
#  started_at  :datetime
#  title       :string
#  type        :string
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_activities_on_creator_id  (creator_id)
#
# Foreign Keys
#
#  fk_rails_...  (creator_id => users.id)
#

# Defines the Activity model
class Activity < ApplicationRecord
  include Lockable
  strip_attributes only: :title, collapse_spaces: true

  belongs_to :creator, class_name: 'User', inverse_of: :activities
  has_many :documents, as: :owner, inverse_of: :owner, dependent: :destroy
  has_and_belongs_to_many :mandates, -> { distinct }
  has_and_belongs_to_many :contacts, -> { distinct }

  has_paper_trail(skip: SKIPPED_ATTRIBUTES)

  validates :type, presence: true
  validates :title, presence: true
  validates :description, presence: true
  validates :started_at, presence: true
  validate :ended_at_greater_or_equal_started_at

  alias_attribute :activity_type, :type

  def task_assignees
    [creator]
  end

  private

  # Validates if started_at timestamp is before ended_at if ended_at is set
  # @return [void]
  def ended_at_greater_or_equal_started_at
    return if ended_at.blank? || started_at.blank? || ended_at >= started_at

    errors.add(:ended_at, 'has to be after or at started_at')
  end
end
