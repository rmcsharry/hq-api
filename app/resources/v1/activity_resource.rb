# frozen_string_literal: true

module V1
  # Defines the Activity resource for the API
  class ActivityResource < BaseResource
    model_hint model: Activity::Call, resource: :activity
    model_hint model: Activity::Email, resource: :activity
    model_hint model: Activity::Meeting, resource: :activity
    model_hint model: Activity::Note, resource: :activity

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

    # rubocop:disable Metrics/MethodLength
    def documents=(params)
      params.each do |param|
        document = @model.documents.build(
          category: param[:category],
          name: param[:name],
          valid_from: param[:'valid-from'],
          valid_to: param[:'valid-to'],
          uploader: @model.creator,
          owner: @model
        )
        document.attach_file(param[:file])
      end
    end
    # rubocop:enable Metrics/MethodLength

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
      records.joins(:contacts).where('contacts.id = ?', value[0])
    }

    filter :mandate_id, apply: lambda { |records, value, _options|
      records.joins(:mandates).where('mandates.id = ?', value[0])
    }

    filter :mandate_group_id, apply: lambda { |records, value, _options|
      records.where(id: Activity.joins(mandates: [:mandate_groups]).where('mandate_groups.id = ?', value[0]))
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
  end
end
