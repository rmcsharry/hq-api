# frozen_string_literal: true

module V1
  # Defines the ForeignTaxNumber controller
  class ForeignTaxNumbersController < ApplicationController
    before_action :authenticate_user!
  end
end
