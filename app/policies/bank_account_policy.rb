# frozen_string_literal: true

# Defines the access permissions for the bank account resource
class BankAccountPolicy < ApplicationPolicy
  # Defines the scope for the bank account resource
  class Scope < Scope
    def resolve
      if request.params['action'] == 'index'
        Scope.accessible_records(scope, user, :mandates_read)
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
    role? :mandates_read
  end

  def show?
    role_applies_to_bank_account?(:mandates_read)
  end

  def create?
    true
  end

  def update?
    true
  end

  def destroy?
    role_applies_to_bank_account?(:mandates_destroy)
  end

  private

  def role_applies_to_bank_account?(role)
    role?(role) &&
      Scope.accessible_records(BankAccount, user, role, id: record.id).count.positive?
  end
end
