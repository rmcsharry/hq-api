# frozen_string_literal: true

module V1
  # Defines the Mandates controller
  class MandatesController < ApplicationController
    before_action :authenticate_user!

    def accessible_fields(scope)
      return { mandates: 'category,owner-name' } if scope == :ews
    end

    def accessible_actions(scope)
      return [:index] if scope == :ews
    end
  end
end
