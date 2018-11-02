# frozen_string_literal: true

module V1
  # Defines the Funds controller
  class FundsController < ApplicationController
    include MultipartRelated

    before_action :authenticate_user!
  end
end
