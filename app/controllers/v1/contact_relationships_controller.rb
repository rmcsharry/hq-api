# frozen_string_literal: true

module V1
  # Defines the ContactRelationships controller
  class ContactRelationshipsController < ApplicationController
    before_action :authenticate_user!
  end
end
