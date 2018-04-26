# frozen_string_literal: true

module V1
  # Defines the Mandate Group resource for the API
  class MandateGroupResource < JSONAPI::Resource
    attributes(:name, :group_type, :updated_at)

    has_many :mandates
    has_many :user_groups
  end
end
