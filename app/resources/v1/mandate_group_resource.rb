# frozen_string_literal: true

module V1
  # Defines the Mandate Group resource for the API
  class MandateGroupResource < BaseResource
    attributes(
      :comment,
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

    sort :mandate_count, apply: lambda { |records, direction, _context|
      records
        .joins(:mandate_groups_mandates)
        .group(:id)
        .order("COUNT(mandate_groups.id) #{direction}")
    }
  end
end
