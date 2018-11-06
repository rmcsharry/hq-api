# frozen_string_literal: true

module V1
  # Defines the Documents controller
  class DocumentsController < ApplicationController
    include MultipartRelated

    before_action :authenticate_user!

    def context
      if params[:action] == 'create'
        super.merge(
          type: params.require(:data).require(:attributes).require('document-type').constantize
        )
      else
        super
      end
    end
  end
end
