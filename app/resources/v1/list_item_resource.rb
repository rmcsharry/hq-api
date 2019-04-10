# frozen_string_literal: true

module V1
  # Defines the ListItemResource
  class ListItemResource < BaseResource
    model_name 'List::Item'

    has_one :list

    attributes(
      :category,
      :comment,
      :listable_id,
      :listable_type,
      :name
    )

    filters(
      :list_id,
      :listable_id,
      :listable_type
    )

    filter :'list.state', apply: lambda { |records, value, _options|
      state = value[0]
      return records if state == 'all'

      records.joins(:list).where('lists.aasm_state = ?', state)
    }

    sort :category, apply: lambda { |records, direction, _options|
      order_by_category(records, direction)
    }

    sort :name, apply: lambda { |records, direction, _options|
      order_by_name(records, direction)
    }

    def category
      return unless @model.listable_type == 'Mandate'

      @model.listable.category
    end

    def name
      case @model.listable_type
      when 'Contact' then @model.listable.decorate.name_list
      when 'Mandate' then @model.listable.decorate.owner_name
      end
    end

    class << self
      def order_by_category(records, direction)
        records.order("mandates.category #{direction}")
      end

      # rubocop:disable Metrics/MethodLength
      def order_by_name(records, direction)
        records.order(%(
          COALESCE(contacts.last_name || ', ' || contacts.first_name, contacts.organization_name) #{direction},
          (SELECT agg.name AS owner_name FROM mandates m LEFT JOIN (
            SELECT mm.mandate_id AS mandate_id,
              STRING_AGG(
                COALESCE(c.last_name || ', ' || c.first_name, c.organization_name), ', '
                ORDER BY c.last_name, c.first_name, c.organization_name
              ) AS name
            FROM mandate_members mm LEFT JOIN contacts c ON mm.contact_id = c.id
            WHERE mm.member_type = 'owner'
            GROUP BY mm.mandate_id
          ) agg ON m.id = agg.mandate_id WHERE m.id = list_items.listable_id) #{direction}
        ))
      end
      # rubocop:enable Metrics/MethodLength

      def records(_options)
        records = super

        records.joins(%(
          LEFT JOIN contacts ON contacts.id = list_items.listable_id AND list_items.listable_type = 'Contact'
          LEFT JOIN mandates ON mandates.id = list_items.listable_id AND list_items.listable_type = 'Mandate'
        ))
      end

      def sortable_fields(_context)
        super + %i[list.name]
      end
    end
  end
end
