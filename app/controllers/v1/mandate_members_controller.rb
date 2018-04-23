# frozen_string_literal: true

module V1
  # Defines the MandateMembers controller
  class MandateMembersController < ApplicationController
    before_action :authenticate_user!
  end
end
