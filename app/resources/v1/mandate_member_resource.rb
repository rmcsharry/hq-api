module V1
  # Defines the Mandate Member resource for the API
  class MandateMemberResource < JSONAPI::Resource
    attributes(:member_type, :start_date, :end_date)

    has_one :contact
    has_one :mandate
  end
end
