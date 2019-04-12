# frozen_string_literal: true

module V1
  # Defines the ListItemsController
  class ListItemsController < ApplicationController
    before_action :authenticate_user!
  end
end
