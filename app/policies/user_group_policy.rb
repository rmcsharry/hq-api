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
    role? :admin
  end

  def update?
    role? :admin
  end

  def destroy?
    role? :admin
  end
end
