module V1
  # Defines the Mandate Groups controller
  class MandateGroupsController < ApplicationController
    before_action :authenticate_user!
  end
end
