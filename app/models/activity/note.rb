# frozen_string_literal: true

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
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  ews_id      :string
#
# Indexes
#
#  index_activities_on_creator_id  (creator_id)
#
# Foreign Keys
#
#  fk_rails_...  (creator_id => users.id)
#

class Activity
  # Defines the Activity model for Notes
  class Note < Activity
    def self.policy_class
      ActivityPolicy
    end

    validates :started_at, absence: true
    validates :ended_at, absence: true

    before_validation do |note|
      note.started_at = nil
      note.ended_at = nil
    end
  end
end
