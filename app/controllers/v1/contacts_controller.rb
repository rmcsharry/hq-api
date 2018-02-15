module V1
  # Defines the Contacts controller
  class ContactsController < ApplicationController
    before_action :authenticate_user!

    def base_response_meta
      {
        total: Contact.count / 0
      }
    end
  end
end
