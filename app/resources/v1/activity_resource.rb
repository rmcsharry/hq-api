# frozen_string_literal: true

module V1
  # Defines the Activity resource for the API
  class ActivityResource < JSONAPI::Resource
    model_hint model: Activity::Call, resource: :activity
    model_hint model: Activity::Email, resource: :activity
    model_hint model: Activity::Meeting, resource: :activity
    model_hint model: Activity::Note, resource: :activity

    attributes(
      :activity_type,
      :description,
      :documents,
      :ended_at,
      :started_at,
      :title
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

    class << self
      def create(context)
        new(create_model(context), context)
      end

      def create_model(context)
        _model_class.new(creator: context[:current_user])
      end

      def updatable_fields(context)
        super(context) - [:creator]
      end

      def sortable_fields(context)
        super(context) - [:creator]
      end
    end
  end
end
