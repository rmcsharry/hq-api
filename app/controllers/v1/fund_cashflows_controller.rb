# frozen_string_literal: true

module V1
  # Defines the FundCashflows controller
  class FundCashflowsController < ApplicationController
    before_action :authenticate_user!
  end
end
