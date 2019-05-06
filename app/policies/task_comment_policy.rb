# frozen_string_literal: true

# Defines the access permissions for the task comment resource
class TaskCommentPolicy < TaskPolicy
  # Defines the scope for the task comment resource
  class Scope < Scope
    def resolve
      if request.params['action'] == 'index'
        Scope.accessible_records(self, scope)
      else
        scope
      end
    end

    def self.accessible_records(target, scope, conditions = {})
      user_id = target.user.id

      scope.where(
        task_id: Task.distinct.joins('LEFT JOIN tasks_users tu ON tasks.id = tu.task_id')
          .where('tasks.creator_id = ? OR tu.user_id = ?', user_id, user_id)
      ).where(conditions)
    end
  end

  def index?
    return false if export?

    role? :tasks
  end

  def show?
    return false if export?

    role?(:tasks) && associated_to_task_comment?
  end

  def create?
    return false if export?

    role? :tasks
  end

  def update?
    return false if export?

    role?(:tasks) && creator_of_task_comment?
  end

  def destroy?
    return false if export?

    role?(:tasks) && creator_of_task_comment?
  end

  private

  def associated_to_task_comment?
    Scope.accessible_records(self, TaskComment, id: record.id).count.positive?
  end

  def creator_of_task_comment?
    !TaskComment.find_by(id: record.id, user_id: user.id).nil?
  end
end
