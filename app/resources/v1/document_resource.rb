# frozen_string_literal: true

module V1
  class DocumentOwnerResource < JSONAPI::Resource; end

  # Defines the Document resource for the API
  class DocumentResource < BaseResource
    custom_action :archive, type: :patch, level: :instance
    custom_action :unarchive, type: :patch, level: :instance

    attributes(
      :category,
      :created_at,
      :document_type,
      :file,
      :file_name,
      :file_type,
      :file_url,
      :name,
      :state,
      :valid_from,
      :valid_to
    )

    has_one :owner, polymorphic: true, class_name: 'DocumentOwner'

    filters :owner_id, :state

    filter :document_type, apply: lambda { |records, value, _options|
      records.where('documents.type = ?', value[0])
    }

    def file_url
      Rails.application.routes.url_helpers.rails_blob_url(@model.file) if @model.file.attached?
    end

    def file_type
      @model.file.content_type if @model.file.attached?
    end

    def file_name
      @model.file.filename.to_s if @model.file.attached?
    end

    def file=(params)
      @model.file.attach(params)
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

    def archive(_data)
      @model.archive!
      @model
    end

    def unarchive(_data)
      @model.unarchive!
      @model
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
        find_klass(type: context[:type]).new(uploader: context[:current_user])
      end

      def updatable_fields(context)
        super(context) - [:file]
      end

      def sortable_fields(context)
        super(context) - [:file]
      end

      def find_klass(type:)
        klass = ([Document] + Document.subclasses).find { |k| k.name == type }
        raise JSONAPI::Exceptions::InvalidFieldValue.new('document-type', type) unless klass

        klass
      end
    end
  end
end
