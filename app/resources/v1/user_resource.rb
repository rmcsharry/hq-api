# frozen_string_literal: true

module V1
  # Defines the User resource for the API
  class UserResource < JSONAPI::Resource
    attributes(
      :comment,
      :confirmed_at,
      :created_at,
      :current_sign_in_at,
      :email,
      :sign_in_count,
      :updated_at,
      :user_group_count
    )

    has_one :contact
    has_many :user_groups

    filters(
      :sign_in_count
    )

    filter :email, apply: lambda { |records, value, _options|
      records.where('users.email ILIKE ?', "%#{value[0]}%")
    }

    filter :"contact.name", apply: lambda { |records, value, _options|
      records.joins(:contact).where(
        "COALESCE(contacts.first_name || ' ' || contacts.last_name, contacts.organization_name) ILIKE ?",
        "%#{value[0]}%"
      )
    }

    filter :user_group_id, apply: lambda { |records, value, _options|
      records.joins(:user_groups).where('user_groups.id = ?', value[0])
    }

    filter :current_sign_in_at_min, apply: lambda { |records, value, _options|
      records.where('users.current_sign_in_at >= ?', Date.parse(value[0]))
    }

    filter :current_sign_in_at_max, apply: lambda { |records, value, _options|
      records.where('users.current_sign_in_at <= ?', Date.parse(value[0]))
    }

    filter :created_at_min, apply: lambda { |records, value, _options|
      records.where('users.created_at >= ?', Date.parse(value[0]))
    }

    filter :created_at_max, apply: lambda { |records, value, _options|
      records.where('users.created_at <= ?', Date.parse(value[0]))
    }

    filter :confirmed_at_min, apply: lambda { |records, value, _options|
      records.where('users.confirmed_at >= ?', Date.parse(value[0]))
    }

    filter :confirmed_at_max, apply: lambda { |records, value, _options|
      records.where('users.confirmed_at <= ?', Date.parse(value[0]))
    }
    filter :updated_at_min, apply: lambda { |records, value, _options|
      records.where('users.updated_at >= ?', Date.parse(value[0]))
    }

    filter :updated_at_max, apply: lambda { |records, value, _options|
      records.where('users.updated_at <= ?', Date.parse(value[0]))
    }

    sort :"contact.name", apply: lambda { |records, direction, _context|
      records.joins(:contact)
             .order(
               "COALESCE(contacts.first_name || ' ' || contacts.last_name, contacts.organization_name) #{direction}"
             )
    }

    class << self
      def records(_options)
        super.with_user_group_count
      end

      def sortable_fields(context)
        super + %i[contact.name]
      end
    end
  end
end
