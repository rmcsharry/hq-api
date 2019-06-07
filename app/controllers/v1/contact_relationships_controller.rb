# frozen_string_literal: true

module V1
  # Defines the ContactRelationships controller
  class ContactRelationshipsController < ApplicationController
    before_action :authenticate_user!

    def context
      if params[:action] == 'index'
        contact_id = params.dig(:filter, :contactId)
        contact_id ? super.merge(contact: Contact.find(contact_id)) : super
      else
        super
      end
    end
  end
end
