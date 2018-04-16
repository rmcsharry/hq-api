module V1
  # Defines the User Groups controller
  class UserGroupsController < ApplicationController
    before_action :authenticate_user!
  end
end
