module V1
  # Defines the Mandates controller
  class MandatesController < ApplicationController
    before_action :authenticate_user!
  end
end
