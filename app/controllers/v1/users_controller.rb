# frozen_string_literal: true

module V1
  # Defines the Users controller
  class UsersController < ApplicationController
    before_action :authenticate_user!, except: %i[read_invitation accept_invitation]

    def read_invitation
      begin
        @response_document = create_response_document
        # rubocop:disable Rails/DynamicFindBy
        user = User.find_by_invitation_token(params[:invitation_token], true)
        # rubocop:enable Rails/DynamicFindBy
        generate_user_response(user: user)
      rescue JSONAPI::Exceptions::Error => e
        handle_exceptions(e)
      end
      render_response_document
    end

    def accept_invitation
      begin
        @response_document = create_response_document
        user = User.accept_invitation!(
          invitation_token: params[:invitation_token], password: params.dig(:data, :password)
        )
        generate_user_response(user: user)
      rescue JSONAPI::Exceptions::Error => e
        handle_exceptions(e)
      end
      render_response_document
    end

    private

    def generate_user_response(user:)
      raise(JSONAPI::Exceptions::RecordNotFound.new(params[:invitation_token]), 'not found') unless user&.valid?
      resource_set = create_resource_set(user: user)
      result = JSONAPI::ResourceSetOperationResult.new(:ok, resource_set)
      operation = JSONAPI::Operation.new(
        :show,
        UserResource,
        serializer: JSONAPI::ResourceSerializer.new(UserResource)
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
