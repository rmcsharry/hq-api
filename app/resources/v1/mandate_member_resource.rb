# frozen_string_literal: true

module V1
  # Defines the Mandate Member resource for the API
  class MandateMemberResource < JSONAPI::Resource
    attributes(:member_type, :start_date, :end_date)

    has_one :contact
    has_one :mandate

    filter :contact_id
    filter :mandate_id

    filter :is_owner, apply: lambda { |records, value, _options|
      is_owner = ActiveRecord::Type::Boolean.new.cast(value[0])
      records.where("member_type #{is_owner ? '=' : '!='} 'owner'")
    }
  end
end
