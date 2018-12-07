# frozen_string_literal: true

# Defines the access permissions for the user resource
class UserPolicy < ApplicationPolicy
  def index?
    role? :admin
  end

  def show?
    return role?(:admin) if export?

    role?(:admin) || user.id == record.id
  end

  def update?
    return false if export?

    role?(:admin) || user.id == record.id
  end

  def destroy?
    role?(:admin) && user.id != record.id
  end
end
