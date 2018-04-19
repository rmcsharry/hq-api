# frozen_string_literal: true

module V1
  # Defines the Activities controller
  class ActivitiesController < ApplicationController
    before_action :authenticate_user!
  end
end
