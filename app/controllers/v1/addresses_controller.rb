module V1
  # Defines the Address controller
  class AddressesController < ApplicationController
    def base_response_meta
      {
        total: Address.count
      }
    end
  end
end
