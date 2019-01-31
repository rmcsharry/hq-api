# frozen_string_literal: true

module V1
  # Defines the Tasks controller
  class TasksController < ApplicationController
    before_action :authenticate_user!
  end
end
