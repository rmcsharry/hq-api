# frozen_string_literal: true

module V1
  # Defines the Base resource for the API
  class BaseResource < JSONAPI::Resource
    include JSONAPI::Authorization::PunditScopedResource
    abstract
  end
end
