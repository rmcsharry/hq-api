# frozen_string_literal: true

# Defines the access permissions for the mandate member resource
class MandateMemberPolicy < ContactPolicy
  # Defines the scope for the mandate member resource
  class Scope < Scope
    def resolve
      if request.params['action'] == 'index'
        mandates_role = export? ? :mandates_export : :mandates_read
        Scope.accessible_records(self, scope, mandates_role)
      else
        scope
      end
    end

    def self.accessible_records(target, scope, role)
      scope.where(
        id: MandateMember.joins(:mandate).where(
          mandates: { id: MandatePolicy::Scope.accessible_records(Mandate.all, target.user, role) }
        )
      )
    end
  end

  def index?
    return role?(:contacts_export, :mandates_export) if export?

    role? :contacts_read, :mandates_read
  end
end
