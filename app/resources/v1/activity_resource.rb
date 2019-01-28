# frozen_string_literal: true

module V1
  # Defines the Activity resource for the API
  class ActivityResource < BaseResource
    attributes(
      :activity_type,
      :created_at,
      :description,
      :documents,
      :ended_at,
      :ews_id,
      :ews_token,
      :ews_url,
      :started_at,
      :title,
      :updated_at
    )

    has_one :creator, class_name: 'User'
    has_many :mandates
    has_many :contacts
    has_many :documents

    def documents=(params)
      params.each do |param|
        document = build_document(params: param)
        document.file.attach(param[:file])
      end
    end

    def activity_type=(params)
      @model.activity_type = params
      @model = @model.becomes(@model.type.constantize)
    end

    def ews_token=(_ews_token) end

    def ews_url=(_ews_url) end

    filters(
      :activity_type
    )

    filter :contact_id, apply: lambda { |records, value, _options|
      records.where(id: Activity.joins(:contacts).where('contacts.id = ?', value[0]))
    }

    filter :mandate_id, apply: lambda { |records, value, _options|
      records.where(id: Activity.joins(:mandates).where('mandates.id = ?', value[0]))
    }

    filter :mandate_group_id, apply: lambda { |records, value, _options|
      records.where(id: Activity.joins(mandates: [:mandate_groups]).where('mandate_groups.id = ?', value[0]))
    }

    filter :started_at, apply: lambda { |records, value, _options|
      records.where('started_at >= ?', Time.zone.parse(value[0]))
    }

    filter :ended_at, apply: lambda { |records, value, _options|
      date = Time.zone.parse(value[0])
      records.where('(ended_at IS NOT NULL AND ended_at <= ?) OR started_at <= ?', date, date)
    }

    filter :query, apply: lambda { |records, value, _options|
      records.left_joins(:documents).where(
        'title ILIKE ? OR description ILIKE ? OR documents.name ILIKE ?',
        "%#{value[0]}%",
        "%#{value[0]}%",
        "%#{value[0]}%"
      )
    }

    def fetchable_fields
      super - %i[ews_id ews_token ews_url]
    end

    class << self
      def create(context)
        new(create_model(context), context)
      end

      def create_model(context)
        _model_class.new(creator: context[:current_user])
      end

      def updatable_fields(context)
        super(context) - %i[creator ews_id ews_token ews_url]
      end

      def sortable_fields(context)
        super(context) - %i[creator ews_id ews_token ews_url]
      end
    end

    private

    def build_document(params:)
      @model.documents.build(
        category: params[:category],
        name: params[:name],
        valid_from: params[:validFrom],
        valid_to: params[:validTo],
        uploader: @model.creator,
        owner: @model
      )
    end
  end
end
