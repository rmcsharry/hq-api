module V1
  class ContactsController < ApplicationController

    def base_response_meta
      {
        total: Contact.count
      }
    end
  end
end
