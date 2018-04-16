module V1
  # Defines the Address controller
  class AddressesController < ApplicationController
    before_action :authenticate_user!
  end
end
