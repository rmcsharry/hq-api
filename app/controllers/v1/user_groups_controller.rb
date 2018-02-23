module V1
  # Defines the User Groups controller
  class UserGroupsController < ApplicationController
    before_action :authenticate_user!

    def base_response_meta
      {
        total: UserGroup.count
      }
    end
  end
end
