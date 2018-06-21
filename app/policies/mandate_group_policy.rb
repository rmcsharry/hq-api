# frozen_string_literal: true

# Defines the access permissions for the mandate group resource
class MandateGroupPolicy < ApplicationPolicy
  # Defines the scope for the mandate group resource
  class Scope < Scope
    def resolve
      if request.params['action'] == 'index'
        Scope.accessible_records(self, scope, :families_read, :admin)
      else
        scope
      end
    end

    def self.accessible_records(target, scope, user_role, admin_role, conditions = {})
      include_scope = target.role?(admin_role) ? scope : scope.includes(user_groups: :users)
      search_scope = include_scope.where(conditions)
      organizations = accessible_organizations search_scope, target, admin_role
      return organizations unless target.role?(user_role)
      organizations.or(accessible_families(search_scope))
    end

    def self.accessible_organizations(scope, target, role)
      if target.role? role
        scope.where(group_type: 'organization')
      else
        scope.where(group_type: 'organization', user_groups_users: { user_id: target.user.id })
      end
    end

    def self.accessible_families(scope)
      scope.where(group_type: 'family')
    end
  end

  def index?
    user.present?
  end

  def show?
    role?(:families_read, :admin) &&
      Scope.accessible_records(self, MandateGroup, :families_read, :admin, id: record.id).count.positive?
  end

  def create?
    conditional_role?(:families_write, request: { 'group-type': 'family' }) ||
      conditional_role?(:admin, request: { 'group-type': 'organization' })
  end

  def update?
    conditional_role?(
      :families_write,
      record: { group_type: 'family' },
      request: { 'group-type': [nil, 'family'] }
    ) ||
      conditional_role?(
        :admin,
        record: { group_type: 'organization' },
        request: { 'group-type': [nil, 'organization'] }
      )
  end

  def destroy?
    conditional_role?(:families_destroy, record: { group_type: 'family' }) ||
      conditional_role?(:admin, record: { group_type: 'organization' })
  end
end
