# frozen_string_literal: true

module V1
  # Defines the Contacts controller
  class ContactsController < ApplicationController
    before_action :authenticate_user!
  end
end
