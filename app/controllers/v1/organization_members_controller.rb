# frozen_string_literal: true

module V1
  # Defines the OrganizationMembers controller
  class OrganizationMembersController < ApplicationController
    before_action :authenticate_user!
  end
end
