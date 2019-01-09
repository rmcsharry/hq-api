# frozen_string_literal: true

# Defines the access permissions for the mandate resource
class MandatePolicy < ApplicationPolicy
  # Defines the scope for the mandate resource
  class Scope < Scope
    def resolve
      if request.params['action'] == 'index'
        role = export? ? :mandates_export : :mandates_read
        Scope.accessible_records(scope, user, role)
      else
        scope
      end
    end

    def self.accessible_records(scope, user, role, conditions = {})
      ids = Mandate.joins(mandate_groups: { user_groups: :users })
                   .where(user_groups_users: { user_id: user.id })
                   .where('user_groups.roles @> ARRAY[?]::varchar[]', [role])

      scope.where(conditions.merge(id: ids))
    end
  end

  def index?
    return role?(:mandates_export) if export?

    role? :mandates_read
  end

  def show?
    return role?(:mandates_export) if export?

    role_applies_to_mandate?(:mandates_read)
  end

  def create?
    return false if export?

    role? :mandates_write
  end

  def update?
    return false if export?

    role_applies_to_mandate?(:mandates_write)
  end

  def destroy?
    return false if export?

    role_applies_to_mandate?(:mandates_destroy)
  end

  private

  def role_applies_to_mandate?(role)
    role?(role) &&
      Scope.accessible_records(Mandate, user, role, id: record.id).count.positive?
  end
end
