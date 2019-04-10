# frozen_string_literal: true

module V1
  # Defines the ListsController
  class ListsController < ApplicationController
    before_action :authenticate_user!
  end
end
