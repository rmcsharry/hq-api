# frozen_string_literal: true

module V1
  # Defines the ContactDetails controller
  class ContactDetailsController < ApplicationController
    before_action :authenticate_user!
  end
end
