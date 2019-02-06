# frozen_string_literal: true

# == Schema Information
#
# Table name: tasks
#
#  id                 :uuid             not null, primary key
#  creator_id         :uuid
#  finisher_id        :uuid
#  subject_type       :string
#  subject_id         :uuid
#  linked_object_type :string
#  linked_object_id   :uuid
#  aasm_state         :string           not null
#  description        :string
#  title              :string           not null
#  type               :string           not null
#  finished_at        :datetime
#  due_at             :datetime
#  created_at         :datetime         not null
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

# Defines the Task model
class Task < ApplicationRecord
  include AASM

  belongs_to :creator, inverse_of: :created_tasks, class_name: 'User', autosave: true, optional: true
  belongs_to :finisher, inverse_of: :finished_by_user_tasks, class_name: 'User', autosave: true, optional: true
  belongs_to :subject, inverse_of: :reminders, polymorphic: true, optional: true
  belongs_to :linked_object, inverse_of: :task_links, polymorphic: true, optional: true
  has_and_belongs_to_many :assignees, -> { distinct }, join_table: :tasks_users, class_name: 'User'

  alias_attribute :task_type, :type

  has_paper_trail(
    meta: {
      parent_item_id: :id,
      parent_item_type: 'Task'
    },
    skip: SKIPPED_ATTRIBUTES
  )

  scope :associated_to_user_with_id, lambda { |user_id|
    joins(
      <<-SQL.squish
        LEFT JOIN tasks_users tu
        ON tasks.id = tu.task_id
      SQL
    )
      .where('tasks.creator_id = ? OR tasks.finisher_id = ? OR tu.user_id = ?', user_id, user_id, user_id)
  }

  aasm do
    state :created, initial: true
    state :finished

    event :finish do
      before :assign_finished_properties
      after :save

      transitions from: %i[created finished], to: :finished
    end

    event :unfinish do
      before :unset_finished_properties
      after :save

      transitions from: %i[created finished], to: :created
    end
  end

  alias_attribute :state, :aasm_state
  alias_attribute :task_type, :type

  validates :title, presence: true
  validate :attributes_in_finished_state

  private

  # Validates presence of finisher and finished_at if state is `finished`
  # @return [void]
  def attributes_in_finished_state
    return unless finished?

    error_message = 'must be present if task is finished'
    errors.add(:finisher, error_message) if finisher.nil?
    errors.add(:finished_at, error_message) if finished_at.nil?
  end

  def assign_finished_properties(finisher)
    self.finisher = finisher
    self.finished_at = Time.zone.now if finished_at.nil?
  end

  def unset_finished_properties
    self.finisher = nil
    self.finished_at = nil
  end
end
