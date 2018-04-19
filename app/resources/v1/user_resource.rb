# frozen_string_literal: true

module V1
  # Defines the User resource for the API
  class UserResource < JSONAPI::Resource
    attributes :email

    has_many :user_groups
  end
end
