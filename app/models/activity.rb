# == Schema Information
#
# Table name: activities
#
#  id          :uuid             not null, primary key
#  type        :string
#  started_at  :datetime
#  ended_at    :datetime
#  title       :string
#  description :text
#  creator_id  :uuid
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
  belongs_to :creator, class_name: 'User', inverse_of: :activities
  has_and_belongs_to_many :mandates
  has_and_belongs_to_many :contacts

  validates :started_at, presence: true
  validates :title, presence: true
  validates :description, presence: true
  validate :ended_at_greater_started_at

  # Validates if started_at timestamp is before ended_at if ended_at is set
  # @return [void]
  def ended_at_greater_started_at
    return if ended_at.blank? || ended_at > started_at
    errors.add(:ended_at, 'has to be after started_at')
  end
end
