# frozen_string_literal: true

module V1
  # Defines the ComplianceDetail resource for the API
  class ComplianceDetailResource < BaseResource
    attributes(
      :wphg_classification, :kagb_classification, :politically_exposed, :occupation_role, :occupation_title,
      :retirement_age
    )

    has_one :contact
  end
end
