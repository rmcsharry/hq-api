# frozen_string_literal: true

# General Application controller
class ApplicationController < JSONAPI::ResourceController
  respond_to :json

  def context
    super.merge current_user: current_user
  end

  def base_response_meta
    {
      total_record_count: resource_klass._model_class.count
    }
  end
end
