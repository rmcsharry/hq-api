# frozen_string_literal: true

# == Schema Information
#
# Table name: tasks
#
#  aasm_state         :string           not null
#  created_at         :datetime         not null
#  creator_id         :uuid
#  description        :string
#  due_at             :datetime
#  finished_at        :datetime
#  finisher_id        :uuid
#  id                 :uuid             not null, primary key
#  linked_object_id   :uuid
#  linked_object_type :string
#  subject_id         :uuid
#  subject_type       :string
#  title              :string           not null
#  type               :string           not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_tasks_on_creator_id                               (creator_id)
#  index_tasks_on_finisher_id                              (finisher_id)
#  index_tasks_on_linked_object_type_and_linked_object_id  (linked_object_type,linked_object_id)
#  index_tasks_on_subject_type_and_subject_id              (subject_type,subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (creator_id => users.id)
#  fk_rails_...  (finisher_id => users.id)
#

class Task
  # Defines the model for user-created tasks
  class Simple < Task
    def self.policy_class
      TaskPolicy
    end

    validates :creator, presence: true
  end
end
