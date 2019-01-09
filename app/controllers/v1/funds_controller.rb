# frozen_string_literal: true

module V1
  # Defines the Funds controller
  class FundsController < ApplicationController
    include MultipartRelated

    before_action :authenticate_user!

    def context
      if params[:action] == 'create'
        super.merge(type: get_fund_type(params: params, required: true))
      elsif params[:action] == 'update'
        super.merge(type: get_fund_type(params: params, required: false))
      else
        super
      end
    end

    private

    def get_fund_type(params:, required:)
      attributes = params.require(:data).require(:attributes)
      fund_type = required ? attributes.require('fund-type') : attributes['fund-type']
      fund_type&.constantize
    end
  end
end
