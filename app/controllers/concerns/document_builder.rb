# frozen_string_literal: false

require 'active_support/concern'

# Adds capability to build documents from templates and data
module DocumentBuilder
  extend ActiveSupport::Concern

  # rubocop:disable Metrics/BlockLength
  included do
    def render_filled_template(template, context)
      return render json: {}, status: :not_found if template.nil?

      authorize template, :show?

      return send_document(template.file.download, template.file.content_type) unless docx?(template)

      filled_template = build_document(template, context)
      send_document(filled_template, Docx::MIME_TYPE)
    end

    private

    def send_document(document, mime_type)
      response.headers['Content-Type'] = mime_type
      send_data document, type: mime_type, status: :created
    end

    def build_document(template, context)
      template_path = load_template(template).path
      document = Docx::Document.new(template_path)
      document.commit(context)
      document.render
    end

    def load_template(template)
      tempfile = Tempfile.new
      tempfile.binmode
      tempfile.write template.file.download
      tempfile.close
      tempfile
    end

    def docx?(template)
      template.file.content_type == Docx::MIME_TYPE
    end
  end
  # rubocop:enable Metrics/BlockLength
end
