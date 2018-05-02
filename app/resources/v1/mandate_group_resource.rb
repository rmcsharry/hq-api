# frozen_string_literal: true

module V1
  # Defines the Mandate Group resource for the API
  class MandateGroupResource < JSONAPI::Resource
    attributes(
      :group_type,
      :mandate_count,
      :name,
      :updated_at
    )

    has_many :mandates
    has_many :user_groups

    filters(
      :group_type
    )

    filter :name, apply: lambda { |records, value, _options|
      records.where('mandate_groups.name ILIKE ?', "%#{value[0]}%")
    }

    filter :user_group_id, apply: lambda { |records, value, _options|
      records.joins(:user_groups).where('user_groups.id = ?', value[0])
    }

    class << self
      def records(_options)
        super.with_mandate_count
      end
    end
  end
end
