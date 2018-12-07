# frozen_string_literal: true

# General Application controller
class ApplicationController < JSONAPI::ResourceController
  include XLSXExportable
  include Pundit

  rescue_from Pundit::NotAuthorizedError, with: :not_authorized
  rescue_from JSONAPI::Exceptions::Unauthorized, with: :not_authorized
  before_action :set_paper_trail_whodunnit
  before_action :filter_inaccessible_fields!

  respond_to :json

  def context
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

  def accessible_fields(_scope)
    {}
  end

  def accessible_actions(_scope)
    []
  end

  private

  def pundit_user
    UserContext.new(current_user, request)
  end

  def filter_inaccessible_fields!
    return unless user_signed_in?

    params['fields'] = accessible_fields(:ews) if ews_request?
  end

  def authenticate_user!
    super

    raise(JSONAPI::Exceptions::Unauthorized.new, 'unauthorized') if token_scope_forbids_action?
  end

  def token_scope_forbids_action?
    ews_request? && !accessible_actions(:ews).include?(params[:action].to_sym)
  end

  def ews_request?
    auth_token_payload['scope'] == 'ews'
  end

  def auth_token_payload
    return @auth_payload if @auth_payload.present?

    auth_header = request.headers['Authorization']&.split(' ')
    return {} if auth_header.blank? || auth_header.size != 2

    @auth_payload = Warden::JWTAuth::TokenDecoder.new.call(auth_header.last)
  end
end
