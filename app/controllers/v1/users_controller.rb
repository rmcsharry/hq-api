# frozen_string_literal: true

module V1
  # Defines the Users controller
  class UsersController < ApplicationController
    before_action :authenticate_user!, except: %i[read_invitation accept_invitation], unless: proc {
      public_action?
    }

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

    def base_response_meta
      public_action? || anonymous_action? ? {} : super
    end

    private

    def public_action?
      params.dig(:custom_action, :method) == :reset_password || params[:action].to_sym == :reset_password
    end

    def anonymous_action?
      params.dig(:custom_action, :method) == :change_password
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
          }
        }
      }
    end
    # rubocop:enable Metrics/MethodLength
  end
end
