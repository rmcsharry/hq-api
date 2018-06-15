# frozen_string_literal: true

# Base class for Application Records
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  SKIPPED_ATTRIBUTES = [:updated_at].freeze
end
