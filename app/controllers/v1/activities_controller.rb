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
      return unless attributes

      ews_id = attributes['ews-id']
      return unless relevant_for_fetch_email_job(ews_id: ews_id, activity_type: attributes['activity-type'])

      activity_id = @response_document.contents['data']['id']

      logger.info "Scheduling to fetch email with id '#{ews_id}' from EWS."
      FetchEmailJob.perform_later(activity_id, id: ews_id, token: attributes['ews-token'], url: attributes['ews-url'])
    end

    def accessible_actions(scope)
      return [:create] if scope == :ews
    end

    private

    def relevant_for_fetch_email_job(ews_id:, activity_type:)
      ews_id.present? && activity_type == 'Activity::Email'
    end
  end
end
