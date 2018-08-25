# frozen_string_literal: true

module V1
  # Defines the InterPersonRelationships controller
  class InterPersonRelationshipsController < ApplicationController
    before_action :authenticate_user!
  end
end
