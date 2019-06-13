# frozen_string_literal: true

module V1
  # Defines the Newsletter Subscriber resource for the API
  class NewsletterSubscriberResource < BaseResource
    include WhitelistedUrl

    attributes(
      :confirmation_base_url,
      :confirmation_sent_at,
      :confirmation_success_url,
      :confirmed_at,
      :created_at,
      :email,
      :first_name,
      :gender,
      :last_name,
      :mailjet_list_id,
      :nobility_title,
      :professional_title,
      :questionnaire_results,
      :state,
      :subscriber_context,
      :updated_at
    )

    filter :email, apply: lambda { |records, value, _options|
      records.where('newsletter_subscribers.email ILIKE ?', "%#{value[0]}%")
    }

    filter :first_name, apply: lambda { |records, value, _options|
      records.where('newsletter_subscribers.first_name ILIKE ?', "%#{value[0]}%")
    }

    filter :last_name, apply: lambda { |records, value, _options|
      records.where('newsletter_subscribers.last_name ILIKE ?', "%#{value[0]}%")
    }

    def confirmation_base_url=(params)
      # To raise ActionController::ParameterMissing error before checking against whitelist
      ActionController::Parameters.new(confirmation_base_url: params).require(:confirmation_base_url)
      check_whitelisted_url!(key: 'confirmation_base_url', url: params)
      @model.confirmation_base_url = params
    end

    def confirmation_success_url=(params)
      # To raise ActionController::ParameterMissing error before checking against whitelist
      ActionController::Parameters.new(confirmation_success_url: params).require(:confirmation_success_url)
      check_whitelisted_url!(key: 'confirmation_success_url', url: params)
      @model.confirmation_success_url = params
    end

    class << self
      def updatable_fields(context)
        super(context) - %i[
          state
          confirmation_sent_at
          confirmed_at
          created_at
          updated_at
        ]
      end
    end
  end
end
