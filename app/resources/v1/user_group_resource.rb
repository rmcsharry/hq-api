# frozen_string_literal: true

module V1
  # Defines the User Group resource for the API
  class UserGroupResource < JSONAPI::Resource
    attributes(
      :comment,
      :name,
      :roles,
      :updated_at,
      :user_count
    )

    has_many :users
    has_many :mandate_groups

    filter :user_id, apply: lambda { |records, value, _options|
      records.joins(:users).where('users.id = ?', value[0])
    }

    filter :name, apply: lambda { |records, value, _options|
      records.where('user_groups.name ILIKE ?', "%#{value[0]}%")
    }

    def roles
      %i[admin mandate_read mandate_write]
    end

    def roles=(_params)
      # TODO: Set roles
    end

    class << self
      def records(_options)
        super.with_user_count
      end
    end
  end
end
