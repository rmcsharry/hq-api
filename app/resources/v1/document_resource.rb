# frozen_string_literal: true

module V1
  # Defines the Document resource for the API
  class DocumentResource < BaseResource
    attributes(
      :category,
      :created_at,
      :file,
      :file_name,
      :file_type,
      :file_url,
      :name,
      :valid_from,
      :valid_to
    )

    has_one :owner, polymorphic: true

    filter :owner_id

    def file_url
      Rails.application.routes.url_helpers.rails_blob_url(@model.file)
    end

    def file_type
      @model.file.content_type
    end

    def file_name
      @model.file.filename.to_s
    end

    def file=(params)
      @model.attach_file(params)
    end

    # TODO: Can be removed when this issue is solved: https://github.com/cerebris/jsonapi-resources/issues/1160
    def _replace_polymorphic_to_one_link(relationship_type, key_value, key_type, _options)
      relationship = self.class._relationships[relationship_type.to_sym]

      send("#{relationship.foreign_key}=", type: self.class.model_name_for_type(key_type), id: key_value)
      @save_needed = true

      :completed
    end

    def fetchable_fields
      super - [:file]
    end

    class << self
      def records(options)
        records = super
        records = records.with_attached_file unless options.dig(:context, :request_method) == 'DELETE'
        records
      end

      def create(context)
        new(create_model(context), context)
      end

      def create_model(context)
        _model_class.new(uploader: context[:current_user])
      end

      def updatable_fields(context)
        super(context) - [:file]
      end

      def sortable_fields(context)
        super(context) - [:file]
      end
    end
  end
end
