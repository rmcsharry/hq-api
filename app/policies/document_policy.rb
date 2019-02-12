# frozen_string_literal: true

# Defines the access permissions for the document resource
class DocumentPolicy < ContactPolicy
  # Defines the scope for the mandate resource
  class Scope < Scope
    def resolve
      if request.params['action'] == 'index'
        action = export? ? :export : :read
        Scope.accessible_records(self, scope, user, action)
      else
        scope
      end
    end

    def self.accessible_records(target, scope, user, action, conditions = {})
      scope = scope.where(conditions)
      target_scope = scope

      mandates_role = "mandates_#{action}".to_sym
      contact_access = target.role?("contacts_#{action}".to_sym)
      mandate_access = target.role?(mandates_role)
      fund_access = target.role?("funds_#{action}".to_sym)

      target_scope = accessible_contacts(scope, target_scope) if contact_access
      target_scope = accessible_mandates(scope, target_scope, user, contact_access, mandates_role) if mandate_access
      target_scope = accessible_funds(scope, target_scope, contact_access, mandate_access) if fund_access

      target_scope
    end

    def self.accessible_contacts(root_scope, target_scope)
      activity_ids = Activity.joins(:contacts).where.not(contacts: { id: nil }).pluck(:id)
      target_scope = target_scope.where(owner_type: 'Contact')
      target_scope.or(root_scope.where(owner_id: activity_ids))
    end

    def self.accessible_funds(root_scope, target_scope, contact_access, mandate_access)
      return target_scope.or(root_scope.where(owner_type: 'Fund')) if contact_access || mandate_access

      target_scope.where(owner_type: 'Fund')
    end

    def self.accessible_mandates(root_scope, target_scope, user, contact_access, mandates_role)
      mandate_ids = Mandate.joins(mandate_groups: { user_groups: :users })
                           .where(user_groups_users: { user_id: user.id })
                           .where('user_groups.roles @> ARRAY[?]::varchar[]', [mandates_role])
                           .pluck(:id)

      accessible_mandate_activities(root_scope, target_scope, mandate_ids, contact_access)
        .or(root_scope.where(owner_id: mandate_ids))
    end

    def self.accessible_mandate_activities(root_scope, target_scope, mandate_ids, contact_access)
      activity_ids = Activity.joins(:mandates).where(mandates: { id: mandate_ids }).pluck(:id)
      return target_scope.or(root_scope.where(owner_id: activity_ids)) if contact_access

      target_scope.where(owner_id: activity_ids)
    end
  end

  def index?
    return role?(:contacts_export, :funds_export, :mandates_export) if export?

    role? :contacts_read, :funds_read, :mandates_read
  end

  def show?
    return role?(:contacts_export, :funds_export, :mandates_export) if export?

    role?(:contacts_read, :funds_read, :mandates_read) &&
      action_permitted_for_document?(:read)
  end

  def create?
    return false if export?

    owner_policy(owner).create?
  end

  def update?
    return false if export?

    owner_policy(record.owner).update?
  end

  def destroy?
    return false if export?

    role?(:contacts_destroy, :funds_destroy, :mandates_destroy) &&
      action_permitted_for_document?(:destroy)
  end

  private

  def action_permitted_for_document?(action)
    Scope.accessible_records(self, Document, user, action, id: record.id).count.positive?
  end

  def owner
    @owner ||= owner_class.find owner_attribute('id')
  end

  def owner_policy(owner)
    @owner_policy ||= Pundit::PolicyFinder.new(owner.class).policy.new(user_context, owner)
  end

  def owner_class
    owner_attribute('type').singularize.camelize.constantize
  end

  def owner_attribute(attribute_name)
    request_data.dig 'relationships', 'owner', 'data', attribute_name
  end

  def request_data
    JSON.parse request.params.dig 'data'
  rescue JSON::ParserError => exception
    Raven.capture_exception(exception)
    request.params.dig 'data'
  end
end
