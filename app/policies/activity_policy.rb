# frozen_string_literal: true

# Defines the access permissions for the activity resource
class ActivityPolicy < ApplicationPolicy
  # Defines the scope for the activity resource
  class Scope < Scope
    def resolve
      if request.params['action'] == 'index'
        Scope.accessible_records(self, scope, :contacts_read, :mandates_read)
      else
        scope
      end
    end

    def self.accessible_records(target, scope, contacts_role, mandates_role, conditions = {})
      new_scope = scope.includes(:contacts, mandates: { mandate_groups: { user_groups: :users } }).where(conditions)
      if target.role?(contacts_role) && target.role?(mandates_role)
        return activities_with_permitted_mandates(new_scope, target.user, mandates_role)
               .or(activities_with_contacts(new_scope))
      elsif target.role?(contacts_role)
        return activities_with_contacts(new_scope)
      elsif target.role?(mandates_role)
        return activities_with_permitted_mandates(new_scope, target.user, mandates_role)
      end
      scope
    end

    def self.activities_with_contacts(scope)
      scope.where.not(contacts: { id: nil })
    end

    def self.activities_with_permitted_mandates(scope, user, role)
      scope
        .where.not(mandates: { id: nil })
        .where(user_groups_users: { user_id: user.id })
        .where('user_groups.roles @> ARRAY[?]::varchar[]', [role])
    end
  end

  def index?
    role? :contacts_read, :mandates_read
  end

  def show?
    roles_apply_to_activity? :contacts_read, :mandates_read
  end

  def create?
    user.present?
  end

  def update?
    roles_apply_to_activity? :contacts_write, :mandates_write
  end

  def destroy?
    roles_apply_to_activity? :contacts_destroy, :mandates_destroy
  end

  private

  def roles_apply_to_activity?(contact_role, mandate_role)
    role?(contact_role, mandate_role) &&
      Scope.accessible_records(self, Activity, contact_role, mandate_role, id: record.id).count.positive?
  end
end
