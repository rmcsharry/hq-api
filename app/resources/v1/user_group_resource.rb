# frozen_string_literal: true

module V1
  # Defines the User Group resource for the API
  class UserGroupResource < JSONAPI::Resource
    attributes :name, :comment

    has_many :users
    has_many :mandate_groups
  end
end
