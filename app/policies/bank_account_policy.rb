# frozen_string_literal: true

# Defines the access permissions for the bank account resource
class BankAccountPolicy < ApplicationPolicy
  # Defines the scope for the bank account resource
  class Scope < Scope
    def resolve
      if request.params['action'] == 'index'
        mandates_role = export? ? :mandates_export : :mandates_read
        funds_role = export? ? :funds_export : :funds_read
        Scope.accessible_records(self, scope, mandates_role, funds_role)
      else
        scope
      end
    end

    def self.accessible_records(target, scope, mandates_role, funds_role, conditions = {})
      new_scope = scope.where(conditions)
      if target.role?(mandates_role) && target.role?(funds_role)
        return bank_accounts_with_permitted_mandates(new_scope, target.user, mandates_role)
               .or(bank_accounts_with_funds(new_scope))
      elsif target.role?(funds_role)
        return bank_accounts_with_funds(new_scope)
      elsif target.role?(mandates_role)
        return bank_accounts_with_permitted_mandates(new_scope, target.user, mandates_role)
      end
      new_scope
    end

    def self.bank_accounts_with_funds(scope)
      scope.where(id: BankAccount.where(owner_type: 'Fund'))
    end

    def self.bank_accounts_with_permitted_mandates(scope, user, role)
      scope.where(
        id: BankAccount.where(
          owner_type: 'Mandate',
          owner_id: MandatePolicy::Scope.accessible_records(Mandate.all, user, role)
        )
      )
    end
  end

  def index?
    return role? :mandates_export, :funds_export if export?

    role? :mandates_read, :funds_read
  end

  def show?
    return roles_apply_to_bank_account? :mandates_export, :funds_export if export?

    roles_apply_to_bank_account? :mandates_read, :funds_read
  end

  def create?
    return false if export?

    role? :mandates_write, :funds_write
  end

  def update?
    return false if export?

    roles_apply_to_bank_account? :mandates_write, :funds_write
  end

  def destroy?
    return false if export?

    roles_apply_to_bank_account? :mandates_destroy, :funds_destroy
  end

  private

  def roles_apply_to_bank_account?(mandates_role, funds_role)
    role?(mandates_role, funds_role) &&
      Scope.accessible_records(self, BankAccount, mandates_role, funds_role, id: record.id).count.positive?
  end
end
