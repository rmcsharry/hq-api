# frozen_string_literal: true

module V1
  # Defines the Versions controller
  class VersionsController < ApplicationController
    before_action :authenticate_user!
  end
end
