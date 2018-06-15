# frozen_string_literal: true

# General Application controller
class ApplicationController < JSONAPI::ResourceController
  before_action :set_paper_trail_whodunnit

  respond_to :json

  def context
    super.merge(
      controller: params['controller'],
      current_user: current_user,
      includes: params['include']&.split(',')&.map { |s| s.underscore.to_sym },
      request_method: request.request_method
    )
  end

  def base_response_meta
    {
      total_record_count: resource_klass._model_class.count
    }
  end
end
