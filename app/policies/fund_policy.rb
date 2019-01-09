# frozen_string_literal: true

# Defines the access permissions for the fund resource
class FundPolicy < ApplicationPolicy
  def index?
    return role?(:funds_export) if export?

    role? :funds_read
  end

  def show?
    return role?(:funds_export) if export?

    role? :funds_read
  end

  def create?
    return false if export?

    role? :funds_write
  end

  def update?
    return false if export?

    role? :funds_write
  end

  def destroy?
    return false if export?

    role? :funds_destroy
  end
end
