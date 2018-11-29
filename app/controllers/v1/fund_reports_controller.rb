# frozen_string_literal: true

module V1
  # Defines the FundReports controller
  class FundReportsController < ApplicationController
    before_action :authenticate_user!
  end
end
