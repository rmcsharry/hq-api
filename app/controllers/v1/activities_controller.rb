# frozen_string_literal: true

module V1
  # Defines the Activities controller
  class ActivitiesController < ApplicationController
    before_action :authenticate_user!

    # rubocop:disable Rails/LexicallyScopedActionFilter
    after_action :check_additional_data, only: :create
    # rubocop:enable Rails/LexicallyScopedActionFilter

    def check_additional_data
      attributes = params[:data][:attributes]
      ews_id = attributes['ews-id'] if attributes

      return if ews_id.blank?

      activity_id = @response_document.contents['data']['id']

      logger.info "Scheduling to fetch email with id '#{ews_id}' from EWS."
      FetchEmailJob.perform_later(activity_id, id: ews_id, token: attributes['ews-token'], url: attributes['ews-url'])
    end

    def accessible_actions(scope)
      return [:create] if scope == :ews
    end
  end
end
