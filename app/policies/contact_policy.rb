# frozen_string_literal: true

# Defines the access permissions for the contact resource
class ContactPolicy < ApplicationPolicy
  def index?
    role? :contacts_read
  end

  def show?
    role? :contacts_read
  end

  def create?
    role? :contacts_write
  end

  def update?
    role? :contacts_write
  end

  def destroy?
    role? :contacts_destroy
  end
end
