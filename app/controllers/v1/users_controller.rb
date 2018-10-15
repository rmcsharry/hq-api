# frozen_string_literal: true

module V1
  # Defines the Users controller
  # rubocop:disable Metrics/ClassLength
  class UsersController < ApplicationController
    include Devise::Controllers::SignInOut

    before_action :authenticate_user!,
                  except: %i[sign_in_ews_id sign_in_user read_invitation accept_invitation],
                  unless: proc { public_action? }

    def sign_in_ews_id
      begin
        @response_document = create_response_document
        id_token = request.headers['Authorization'].split(' ').last
        user = authenticate_ews_id(id_token)
        generate_user_response(user: user)
      rescue JSONAPI::Exceptions::Error => e
        handle_exceptions(e)
      end
      render_response_document
    end

    def sign_in_user
      begin
        @response_document = create_response_document
        attributes = params.require(:data).require(:attributes)
        user = authenticate_user(email: attributes.require(:email), password: attributes.require(:password))
        user.setup_ews_id(attributes.fetch('identity-token', nil))
        generate_user_response(user: user)
      rescue JSONAPI::Exceptions::Error => e
        handle_exceptions(e)
      end
      render_response_document
    end

    def validate_token
      begin
        @response_document = create_response_document
        user = User.where(id: current_user.id).includes(user_groups: [:mandate_groups]).first
        generate_user_response(user: user)
      rescue JSONAPI::Exceptions::Error => e
        handle_exceptions(e)
      end
      render_response_document
    end

    def read_invitation
      begin
        @response_document = create_response_document
        # rubocop:disable Rails/DynamicFindBy
        user = User.find_by_invitation_token(params[:invitation_token], true)
        # rubocop:enable Rails/DynamicFindBy
        raise(JSONAPI::Exceptions::RecordNotFound.new(params[:invitation_token]), 'not found') unless user&.valid?
        generate_user_response(user: user)
      rescue JSONAPI::Exceptions::Error => e
        handle_exceptions(e)
      end
      render_response_document
    end

    def accept_invitation
      begin
        @response_document = create_response_document
        password = params.require(:data).require(:attributes).require(:password)
        user = set_password_by_token(token: params[:invitation_token], password: password)
        generate_user_response(user: user)
      rescue JSONAPI::Exceptions::Error => e
        handle_exceptions(e)
      end
      render_response_document
    end

    def reset_password
      begin
        @response_document = create_response_document
        password = params.require(:data).require(:attributes).require(:password)
        user = reset_password_by_token(token: params[:reset_password_token], password: password)
        generate_user_response(user: user, serializer: nil)
      rescue JSONAPI::Exceptions::Error => e
        handle_exceptions(e)
      end
      render_response_document
    end

    # rubocop:disable Metrics/MethodLength
    def deactivate
      begin
        @response_document = create_response_document
        user = User.find(params.require(:id))
        authorize user, :update?
        raise(JSONAPI::Exceptions::DeactivateSelf.new, 'forbidden') if user == current_user
        user.deactivate!
        generate_user_response(user: user)
      rescue JSONAPI::Exceptions::Error => e
        handle_exceptions(e)
      end
      render_response_document
    end
    # rubocop:enable Metrics/MethodLength

    def reactivate
      begin
        @response_document = create_response_document
        user = User.find(params.require(:id))
        authorize user, :update?
        user.reactivate!
        generate_user_response(user: user)
      rescue JSONAPI::Exceptions::Error => e
        handle_exceptions(e)
      end
      render_response_document
    end

    def base_response_meta
      public_action? || anonymous_action? ? {} : super
    end

    private

    def public_action?
      params.dig(:custom_action, :method) == :reset_password || params[:action].to_sym == :reset_password
    end

    def anonymous_action?
      params.dig(:custom_action, :method) == :change_password || params[:action].to_sym == :sign_in_ews_id
    end

    def authenticate_user(email:, password:)
      request.env['action_dispatch.request.parameters'] = { user: { email: email, password: password } }
      request.env['devise.allow_params_authentication'] = true
      user = nil
      catch(:warden) do
        user = warden.authenticate!(scope: :user)
      end
      raise(JSONAPI::Exceptions::Unauthorized.new, 'unauthorized') unless user
      # Reload user to include mandate groups
      user = User.where(id: user.id).includes(user_groups: [:mandate_groups]).first
      sign_in(:user, user)
      user
    end

    def authenticate_ews_id(id_token)
      user = AuthenticateEWSIdTokenService.call id_token
      raise(JSONAPI::Exceptions::RecordNotFound.new(id_token), 'not found') unless user
      user = User.where(id: user.id).includes(user_groups: [:mandate_groups]).first
      user.authenticated_via_ews = true
      sign_in :user, user
      user
    end

    def set_password_by_token(token:, password:)
      user = User.accept_invitation!(invitation_token: token, password: password)
      raise(JSONAPI::Exceptions::RecordNotFound.new(token), 'not found') unless user&.valid?
      user
    end

    def reset_password_by_token(token:, password:)
      user = User.reset_password_by_token(reset_password_token: token, password: password)
      raise(JSONAPI::Exceptions::RecordNotFound.new(token), 'not found') if user.id.nil?
      user.save!
      user
    rescue ActiveRecord::RecordInvalid
      raise(JSONAPI::Exceptions::ValidationErrors.new(UserResource.new(user, {})), 'not valid')
    end

    def generate_user_response(user:, serializer: JSONAPI::ResourceSerializer.new(UserResource))
      resource_set = create_resource_set(user: user)
      result = JSONAPI::ResourceSetOperationResult.new(:ok, resource_set)
      operation = JSONAPI::Operation.new(
        :show,
        UserResource,
        serializer: serializer
      )
      response_document.add_result(result, operation)
    end

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def create_resource_set(user:)
      {
        'UserResource' => {
          user.id => {
            primary: true,
            resource: UserResource.new(User.with_user_group_count.find(user.id), nil),
            relationships: {
              contact: { rids: [JSONAPI::ResourceIdentity.new(ContactResource, user.contact.id)] },
              user_groups: {
                rids: user.user_groups.map { |ug| JSONAPI::ResourceIdentity.new(UserGroupResource, ug.id) }
              }
            }
          },
          user.contact.id => {
            resource: ContactResource.new(user.contact.decorate, nil),
            relationships: {}
          }
        }
      }
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize
  end
  # rubocop:enable Metrics/ClassLength
end
