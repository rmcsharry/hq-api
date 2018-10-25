# frozen_string_literal: true

module V1
  # Defines the Documents controller
  class DocumentsController < ApplicationController
    include MultipartRelated

    before_action :authenticate_user!
  end
end
