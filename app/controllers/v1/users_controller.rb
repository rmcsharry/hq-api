# frozen_string_literal: true

module V1
  # Defines the Users controller
  class UsersController < ApplicationController
    before_action :authenticate_user!
  end
end
