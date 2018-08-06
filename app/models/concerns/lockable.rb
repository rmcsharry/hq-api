# frozen_string_literal: true

# Concern to lock models 24 hours after creation so that they become readable only afterwards
module Lockable
  extend ActiveSupport::Concern

  included do
    before_destroy :prevent_destruction, if: :readonly?, prepend: true
  end

  def readonly?
    created_at && created_at < 1.day.ago
  end

  def prevent_destruction
    raise ActiveRecord::ReadOnlyRecord
  end
end
