# frozen_string_literal: true

# Defines the access permissions for the activity resource
class ActivityPolicy < ApplicationPolicy
  # Defines the scope for the activity resource
  class Scope < Scope
    def resolve
      if request.params['action'] == 'index'
        contacts_role = export? ? :contacts_export : :contacts_read
        mandates_role = export? ? :mandates_export : :mandates_read
        Scope.accessible_records(self, scope, contacts_role, mandates_role)
      else
        scope
      end
    end

    def self.accessible_records(target, scope, contacts_role, mandates_role, conditions = {})
      new_scope = scope.includes(:contacts, :mandates).where(conditions)
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
      scope.where(
        mandates: {
          id: MandatePolicy::Scope.accessible_records(Mandate.all, user, role)
        }
      )
    end
  end

  def index?
    return role?(:contacts_export, :mandates_export) if export?
    role? :contacts_read, :mandates_read
  end

  def show?
    return roles_apply_to_activity?(:contacts_export, :mandates_export) if export?
    roles_apply_to_activity? :contacts_read, :mandates_read
  end

  def create?
    return false if export?
    user.present?
  end

  def update?
    return false if export?
    roles_apply_to_activity? :contacts_write, :mandates_write
  end

  def destroy?
    return false if export?
    roles_apply_to_activity? :contacts_destroy, :mandates_destroy
  end

  private

  def roles_apply_to_activity?(contact_role, mandate_role)
    role?(contact_role, mandate_role) &&
      Scope.accessible_records(self, Activity, contact_role, mandate_role, id: record.id).count.positive?
  end
end
