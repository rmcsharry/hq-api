module V1
  # Defines the Documents controller
  class DocumentsController < ApplicationController
    before_action :authenticate_user!
  end
end
