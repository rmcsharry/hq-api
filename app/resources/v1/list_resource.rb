# frozen_string_literal: true

module V1
  # Defines the ListResource
  class ListResource < BaseResource
    custom_action :archive, level: :instance, type: :patch

    has_many :contacts
    has_many :mandates

    attributes(
      :comment,
      :contact_count,
      :mandate_count,
      :name,
      :state,
      :updated_at,
      :user_name
    )

    filter :listable_not_in_list, apply: lambda { |records, value, _options|
      records.where(%(
        lists.id NOT IN (
          SELECT list_items.list_id FROM list_items
          WHERE list_items.listable_id = ? AND list_items.listable_type = ?
        )
      ), value[0]['id'], value[0]['type'])
    }

    filter :name, apply: lambda { |records, value, _options|
      records.where('lists.name ILIKE ?', "%#{value[0]}%")
    }

    filter :state, apply: lambda { |records, value, _options|
      state = value[0]
      return records if state == 'all'

      records.where(state: state)
    }

    sort :contact_count, apply: lambda { |records, direction, _context|
      records.left_joins(:contacts).group(:id).order("COUNT(contacts.id) #{direction}")
    }

    sort :mandate_count, apply: lambda { |records, direction, _context|
      records.left_joins(:mandates).group(:id).order("COUNT(mandates.id) #{direction}")
    }

    def archive(_data)
      @model.archive!
      @model
    end

    def contact_count
      @model.contacts.count
    end

    def mandate_count
      @model.mandates.count
    end

    def user_name
      @model.user&.contact&.decorate&.name
    end

    def self.create(context)
      user = context[:current_user]
      new(_model_class.new(user: user), nil)
    end
  end
end
