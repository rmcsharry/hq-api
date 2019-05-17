# frozen_string_literal: true

# == Schema Information
#
# Table name: task_comments
#
#  comment    :text
#  created_at :datetime         not null
#  id         :uuid             not null, primary key
#  task_id    :uuid             not null
#  updated_at :datetime         not null
#  user_id    :uuid             not null
#
# Indexes
#
#  index_task_comments_on_task_id  (task_id)
#  index_task_comments_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (task_id => tasks.id)
#  fk_rails_...  (user_id => users.id)
#

# Defines the Comment for a Task
class TaskComment < ApplicationRecord
  belongs_to :task
  belongs_to :user
  has_one :contact, through: :user

  validates :comment, presence: true

  has_paper_trail(
    meta: {
      parent_item_id: :task_id,
      parent_item_type: 'Task'
    },
    skip: SKIPPED_ATTRIBUTES
  )
end
