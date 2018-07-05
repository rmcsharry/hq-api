# frozen_string_literal: true

# General Application controller
class ApplicationController < JSONAPI::ResourceController
  rescue_from Pundit::NotAuthorizedError, with: :not_authorized
  before_action :set_paper_trail_whodunnit

  respond_to :json

  def context
    p "Origin: #{request.origin}"
    super.merge(
      controller: params['controller'],
      current_user: current_user,
      includes: params['include']&.split(',')&.map { |s| s.underscore.to_sym },
      pundit_user: pundit_user,
      request_method: request.request_method
    )
  end

  def base_response_meta
    {
      total_record_count: scoped_resource.count
    }
  end

  def not_authorized
    head :forbidden
  end

  protected

  def scoped_resource
    finder = Pundit::PolicyFinder.new(resource_klass._model_class)
    finder.scope.new(pundit_user, resource_klass._model_class).resolve
  end

  private

  def pundit_user
    UserContext.new(current_user, request)
  end
end
