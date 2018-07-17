# frozen_string_literal: true

module V1
  # Defines the Base resource for the API
  class BaseResource < JSONAPI::Resource
    include JSONAPI::Authorization::PunditScopedResource
    abstract

    protected

    def sanitize_params(params, resource)
      params.transform_keys { |key| key.to_s.underscore }.permit(resource._attributes.keys)
    end
  end
end
