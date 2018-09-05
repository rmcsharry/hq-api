# frozen_string_literal: true

module V1
  # Defines the compliance details controller
  class ComplianceDetailsController < ApplicationController
    before_action :authenticate_user!
  end
end
