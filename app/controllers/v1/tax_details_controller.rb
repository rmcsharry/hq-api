# frozen_string_literal: true

module V1
  # Defines the TaxDetails controller
  class TaxDetailsController < ApplicationController
    before_action :authenticate_user!
  end
end
