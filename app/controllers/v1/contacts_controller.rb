# frozen_string_literal: true

module V1
  # Defines the Contacts controller
  class ContactsController < ApplicationController
    before_action :authenticate_user!

    def accessible_fields(scope)
      return { contacts: 'contact-type,first-name,last-name,name' } if scope == :ews
    end

    def accessible_actions(scope)
      return [:index] if scope == :ews
    end
  end
end
