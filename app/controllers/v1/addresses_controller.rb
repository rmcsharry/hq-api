module V1
  # Defines the Address controller
  class AddressesController < ApplicationController
    before_action :authenticate_user!

    def base_response_meta
      {
        total: Address.count
      }
    end
  end
end
