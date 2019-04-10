# frozen_string_literal: true

# Defines the ListPolicy
class ListPolicy < ApplicationPolicy
  def index?
    role_lists?(export: true)
  end

  def show?
    role_lists?(export: true)
  end

  def create?
    role_lists?
  end

  def update?
    role_lists?
  end

  def destroy?
    role_lists?
  end

  private

  def role_lists?(export: false)
    return export && role?(:lists) if export?

    role? :lists
  end
end
