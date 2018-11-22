# frozen_string_literal: true

module V1
  # Defines the Funds controller
  class FundsController < ApplicationController
    include MultipartRelated

    before_action :authenticate_user!

    def context
      if %w[create update].include? params[:action]
        super.merge(
          type: params.require(:data).require(:attributes).require('fund-type').constantize
        )
      else
        super
      end
    end
  end
end
