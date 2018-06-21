# frozen_string_literal: true

# Defines the applications root policy
class ApplicationPolicy < PolicyWithRoles
  # Defines root scope of policies for e.g. narrowing results based on roles
  class Scope < PolicyWithRoles
    attr_reader :scope

    def initialize(user_context, scope)
      super(user_context)
      @scope = scope
    end

    def resolve
      scope.all
    end
  end

  attr_reader :record

  def initialize(user_context, record)
    super(user_context)
    @record = record
  end
end
