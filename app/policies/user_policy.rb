# frozen_string_literal: true

# Defines the access permissions for the user resource
class UserPolicy < ApplicationPolicy
  def index?
    role? :admin
  end

  def show?
    role?(:admin) || user.id == record.id
  end
end
