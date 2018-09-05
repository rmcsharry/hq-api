# frozen_string_literal: true

# Defines the access permissions for the user group resource
class UserGroupPolicy < ApplicationPolicy
  def index?
    role? :admin
  end

  def show?
    role? :admin
  end

  def create?
    return false if export?
    role? :admin
  end

  def update?
    return false if export?
    role? :admin
  end

  def destroy?
    return false if export?
    role? :admin
  end
end
