# frozen_string_literal: true

# Defines the access permissions for the bank account resource
class BankAccountPolicy < ApplicationPolicy
  # Defines the scope for the bank account resource
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
      scope
        .includes(mandate: { mandate_groups: { user_groups: :users } })
        .where(conditions.merge(user_groups_users: { user_id: user.id }))
        .where('user_groups.roles @> ARRAY[?]::varchar[]', [role])
    end
  end

  def index?
    return role?(:mandates_export) if export?
    role? :mandates_read
  end

  def show?
    return role_applies_to_bank_account?(:mandates_export) if export?
    role_applies_to_bank_account?(:mandates_read)
  end

  def create?
    return false if export?
    true
  end

  def update?
    return false if export?
    true
  end

  def destroy?
    return false if export?
    role_applies_to_bank_account?(:mandates_destroy)
  end

  private

  def role_applies_to_bank_account?(role)
    role?(role) &&
      Scope.accessible_records(BankAccount, user, role, id: record.id).count.positive?
  end
end
