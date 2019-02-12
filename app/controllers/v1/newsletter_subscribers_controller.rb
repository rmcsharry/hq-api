# frozen_string_literal: true

module V1
  # Defines the Newsletter Subscribers controller
  class NewsletterSubscribersController < ApplicationController
    # rubocop:disable Rails/LexicallyScopedActionFilter
    before_action :authenticate_user!, except: %i[create confirm_subscription]
    # rubocop:enable Rails/LexicallyScopedActionFilter

    def base_response_meta
      return {} if action_name == 'create'

      super
    end

    def confirm_subscription
      subscriber = NewsletterSubscriber.confirm_by_token!(params[:confirmation_token])
      if subscriber.present?
        redirect_to subscriber.confirmation_success_url
      else
        redirect_to ENV['NEWSLETTER_SUBSCRIBER_CONFIRMATION_FAILURE_URL']
      end
    end
  end
end
