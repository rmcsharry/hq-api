# frozen_string_literal: true

module V1
  # Defines the Document resource for the API
  class DocumentResource < JSONAPI::Resource
    attributes(
      :category,
      :created_at,
      :name,
      :file_url,
      :valid_from,
      :valid_to
    )

    has_one :owner, polymorphic: true

    filter :owner_id

    def file_url
      Rails.application.routes.url_helpers.rails_blob_url(@model.file)
    end

    class << self
      def records(_options)
        super.includes(file_attachment: [:blob])
      end
    end
  end
end
