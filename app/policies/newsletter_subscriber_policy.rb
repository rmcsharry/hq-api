# frozen_string_literal: true

# Defines the access permissions for the Newsletter Subscriber resource
class NewsletterSubscriberPolicy < ApplicationPolicy
  def index?
    return role?(:contacts_export) if export?

    role? :contacts_read
  end

  def show?
    return role?(:contacts_export) if export?

    role? :contacts_read
  end

  def create?
    return false if export?

    true
  end

  def update?
    return false if export?

    role? :contacts_write
  end

  def destroy?
    return false if export?

    role? :contacts_destroy
  end
end
