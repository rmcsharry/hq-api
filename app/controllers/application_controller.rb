# General Application controller
class ApplicationController < JSONAPI::ResourceController
  respond_to :json

  def base_response_meta
    {
      total_record_count: resource_klass._model_class.count
    }
  end
end
