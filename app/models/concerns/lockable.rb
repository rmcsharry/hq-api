# frozen_string_literal: true

# Concern to lock models 24 hours after creation so that they become readable only afterwards
module Lockable
  extend ActiveSupport::Concern

  included do
    before_destroy :prevent_destruction, if: :grace_period_expired?, prepend: true
    before_update :protect_readonly_attributes, if: :grace_period_expired?, prepend: true
  end

  def grace_period_expired?
    created_at && created_at < 1.day.ago
  end

  def protect_readonly_attributes
    return if (changes.keys - unlocked_attributes).size.zero?

    raise ActiveRecord::ReadOnlyRecord
  end

  # Including classes may override this method and return an array of attribute names
  # that are not readonly even after grace period expired.
  # @return [string[]]
  def unlocked_attributes
    []
  end

  def prevent_destruction
    raise ActiveRecord::ReadOnlyRecord
  end
end
