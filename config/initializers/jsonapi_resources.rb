# frozen_string_literal: true

JSONAPI.configure do |config|
  config.default_paginator = :paged
  config.default_page_size = 10
  config.maximum_page_size = 100
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
