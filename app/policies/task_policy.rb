# frozen_string_literal: true

# Defines the access permissions for the task resource
class TaskPolicy < ApplicationPolicy
  # Defines the scope for the task resource
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
      scope
        .select('DISTINCT(tasks.*)')
        .joins('LEFT JOIN tasks_users tu ON tasks.id = tu.task_id')
        .where(conditions)
        .where('tasks.creator_id = ? OR tu.user_id = ?', user_id, user_id)
    end
  end

  def index?
    return false if export?

    role? :tasks
  end

  def show?
    return false if export?

    role?(:tasks) && associated_to_task?
  end

  def create?
    return false if export?

    role? :tasks
  end

  def update?
    return false if export?

    role?(:tasks) && associated_to_task?
  end

  def destroy?
    return false if export?

    role?(:tasks) && creator_of_task?
  end

  private

  def associated_to_task?
    Scope.accessible_records(self, Task, id: record.id).count.positive?
  end

  def creator_of_task?
    !Task.find_by(id: record.id, creator_id: user.id).nil?
  end
end
