# frozen_string_literal: true

module V1
  # Defines the ContactDetails controller
  class ContactDetailsController < ApplicationController
    before_action :authenticate_user!

    def context
      if params[:action] == 'create'
        super.merge(
          type: params.require(:data).require(:attributes).require('contact-detail-type').classify
        )
      else
        super
      end
    end
  end
end
