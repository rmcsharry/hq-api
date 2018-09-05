# frozen_string_literal: true

require 'active_support/concern'

# Adds capability to render resources as .xlsx files when appropriate
# content-type is given
module XLSXExportable
  extend ActiveSupport::Concern

  XLSX_MIME_TYPE = Mime[:xlsx].to_s.freeze

  included do # rubocop:disable Metrics/BlockLength
    def render_response_document
      return render_xlsx_document if request.format == XLSX_MIME_TYPE
      super
    end

    def valid_accept_media_type?
      media_types = media_types_for('Accept')

      media_types.blank? || media_types.any? do |media_type|
        (media_type == JSONAPI::MEDIA_TYPE ||
         media_type == XLSX_MIME_TYPE ||
         media_type.start_with?(JSONAPI::ActsAsResourceController::ALL_MEDIA_TYPES))
      end
    end

    private

    def serialization_options
      format = request.format == XLSX_MIME_TYPE ? :xlsx : :json
      {
        format: format
      }
    end

    def render_xlsx_document
      response_status = response_document.status
      return render(json: nil, status: response_status) if response_status != 200

      worksheets = FormatResponseDocumentService.call response_document.contents
      return render(json: nil, status: :no_content) if worksheets.empty?

      render_worksheets(worksheets)
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def render_worksheets(worksheets)
      package = Axlsx::Package.new use_shared_strings: true

      valid_worksheets = worksheets.reject do |_, resources|
        resources.size <= 1
      end

      valid_worksheets.each do |type, resources|
        package.workbook.add_worksheet(name: type) do |worksheet|
          types = cell_types(resources.first)
          resources.each_with_index do |resource, index|
            options = index.zero? ? {} : { types: types }
            worksheet.add_row resource, options
          end
        end
      end

      response.headers['Content-Type'] = XLSX_MIME_TYPE
      send_data package.to_stream.string, type: XLSX_MIME_TYPE, disposition: :attachment
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    def cell_types(headers)
      headers.map do |_|
        :string
      end
    end
  end
end
