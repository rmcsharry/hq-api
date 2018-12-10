# frozen_string_literal: true

require 'active_support/concern'

# Adds capability to build documents from templates and data
module DocumentBuilder
  extend ActiveSupport::Concern

  DOCX_MIME_TYPE = Mime[:docx].to_s.freeze

  included do
    def render_filled_template(template, context)
      authorize template, :show?

      filled_template = build_document(template, context)

      response.headers['Content-Type'] = DOCX_MIME_TYPE
      send_file filled_template, type: DOCX_MIME_TYPE, status: :created
      filled_template.close
    end

    private

    def build_document(template, context)
      template_path = load_template(template).path
      document = DocxReplace::Doc.new(template_path)

      context.to_dotted_hash.each do |key, value|
        document.replace("{#{key}}", value)
      end

      filled_template = Tempfile.new
      document.commit(filled_template.path)
      filled_template
    end

    def load_template(template)
      tempfile = Tempfile.new
      tempfile.binmode
      tempfile.write template.file.download
      tempfile.close
      tempfile
    end
  end
end
