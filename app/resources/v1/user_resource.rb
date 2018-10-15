# frozen_string_literal: true

module V1
  # Defines the User resource for the API
  # rubocop:disable Metrics/ClassLength
  class UserResource < BaseResource
    include WhitelistedUrl

    custom_action :invite, type: :post, level: :collection
    custom_action :reset_password, type: :post, level: :collection
    custom_action :set_password, method: :change_password, type: :post, level: :collection

    attributes(
      :comment,
      :confirmed_at,
      :created_at,
      :current_sign_in_at,
      :deactivated_at,
      :email,
      :ews_user_id,
      :roles,
      :sign_in_count,
      :updated_at,
      :user_group_count
    )

    has_one :contact
    has_many :user_groups

    def roles
      roles = {}
      @model.user_groups.includes(:mandate_groups).each do |user_group|
        user_group.roles.each { |r| roles[r] = [roles[r], user_group.mandate_groups.map(&:id)].flatten.compact }
      end
      roles.map do |key, value|
        role = { key: key }
        role[:mandate_groups] = value.uniq if key.start_with? 'mandates'
        role
      end
    end

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

    filter :deactivated_at_min, apply: lambda { |records, value, _options|
      records.where('users.deactivated_at >= ?', Date.parse(value[0]))
    }

    filter :deactivated_at_max, apply: lambda { |records, value, _options|
      records.where('users.deactivated_at <= ?', Date.parse(value[0]))
    }

    filter :ews_user_id, apply: lambda { |records, value, _options|
      records.where('users.ews_user_id ILIKE ?', "%#{value[0]}%")
    }

    sort :"contact.name", apply: lambda { |records, direction, _context|
      records.joins(:contact)
             .order(
               "COALESCE(contacts.first_name || ' ' || contacts.last_name, contacts.organization_name) #{direction}"
             )
    }

    # rubocop:disable Metrics/AbcSize
    def invite(data)
      user_group_ids = data.require(:relationships).require(:user_groups).require(:data).map { |ug| ug.require(:id) }
      invite_user!(
        email: data.require(:attributes).require(:email),
        ews_user_id: data.require(:attributes)[:ews_user_id],
        contact: Contact.find(data.require(:relationships).require(:contact).require(:data).require(:id)),
        user_groups: UserGroup.find(user_group_ids),
        set_password_url: data.require(:attributes).require(:set_password_url)
      )
    end
    # rubocop:enable Metrics/AbcSize

    def reset_password(data)
      sleep(rand * 0.5 + 0.5) # Random delay between 0.5 and 1.0 seconds to obscure if the email exists
      email = data.require(:attributes).require(:email).downcase
      reset_password_url = data.require(:attributes).require(:reset_password_url)
      check_whitelisted_url!(key: 'reset_password_url', url: reset_password_url)
      User.send_reset_password_instructions(email: email, reset_password_url: reset_password_url)
    end

    def change_password(data)
      user = context[:current_user]
      user.password = data.require(:attributes).require(:password)
      user.save!
    rescue ActiveRecord::RecordInvalid
      raise JSONAPI::Exceptions::ValidationErrors, self.class.new(user, {})
    end

    class << self
      def records(_options)
        super.with_user_group_count
      end

      def updatable_fields(context)
        super(context) - %i[roles]
      end

      def sortable_fields(context)
        super(context) + %i[contact.name] - %i[roles]
      end
    end

    private

    # rubocop:disable Metrics/MethodLength
    def invite_user!(email:, contact:, user_groups:, set_password_url:, ews_user_id:)
      check_whitelisted_url!(key: 'set_password_url', url: set_password_url)
      User.invite!(
        {
          email: email,
          contact: contact,
          user_groups: user_groups,
          ews_user_id: ews_user_id
        },
        nil,
        set_password_url: set_password_url
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
  # rubocop:enable Metrics/ClassLength
end
