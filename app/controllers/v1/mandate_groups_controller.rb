# frozen_string_literal: true

module V1
  # Defines the Mandate Groups controller
  class MandateGroupsController < ApplicationController
    before_action :authenticate_user!

    def base_response_meta
      {
        total_record_count: total_record_count
      }
    end

    private

    def total_record_count
      type_filter = params.dig(:filter, :group_type)
      return scoped_resource.count if type_filter.blank?
      return scoped_resource.families.count if type_filter == 'family'
      scoped_resource.organizations.count
    end
  end
end
