module V1
  # Defines the Contacts controller
  class ContactsController < ApplicationController
    def base_response_meta
      {
        total: Contact.count
      }
    end
  end
end
