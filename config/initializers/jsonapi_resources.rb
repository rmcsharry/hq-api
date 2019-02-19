# frozen_string_literal: true

JSONAPI.configure do |config|
  config.default_paginator = :paged
  config.default_page_size = 10
  config.maximum_page_size = 1000
  config.top_level_meta_include_record_count = true
  config.top_level_meta_include_page_count = true
  config.resource_key_type = :uuid

  config.default_processor_klass = JSONAPI::Authorization::AuthorizingProcessor
  config.exception_class_whitelist = [Pundit::NotAuthorizedError]
  config.whitelist_all_exceptions = true
end

JSONAPI::Authorization.configure do |config|
  config.pundit_user = :pundit_user
end

module JSONAPI
  # JSONAPI::Resources extension of the Resource class
  class Resource
    class << self
      # rubocop:disable Metrics/AbcSize
      def resource_klass_for(type)
        type = type.underscore
        type = _model_hints[type] if _model_hints && _model_hints[type]
        type_with_module = type.start_with?(module_path) ? type : module_path + type

        resource_name = _resource_name_from_type(type_with_module)
        resource = resource_name.safe_constantize if resource_name
        if resource.nil?
          raise NameError, "JSONAPI: Could not find resource '#{type}'. (Class #{resource_name} not found)"
        end

        resource
      end
      # rubocop:enable Metrics/AbcSize
    end
  end
end

module JSONAPI
  # JSONAPI::Resources extension of the Relationship class
  class Relationship
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Style/CaseEquality
    def self.polymorphic_types(name)
      @poly_hash ||= {}.tap do |hash|
        ObjectSpace.each_object do |klass|
          next if !(Module === klass) || klass.name.nil? || !(ActiveRecord::Base > klass)

          klass.reflect_on_all_associations(:has_many).select { |r| r.options[:as] }.each do |reflection|
            (hash[reflection.options[:as]] ||= []) << klass.name.underscore
          end
        end
      end
      @poly_hash[name.to_sym]
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Style/CaseEquality
  end
end
