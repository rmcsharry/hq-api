# frozen_string_literal: false

require 'active_support/concern'

# Adds capability to build documents from templates and data
module DocumentBuilder
  extend ActiveSupport::Concern

  DOCX_MIME_TYPE = Mime[:docx].to_s.freeze
  XML_TAG = /\<[^\>]+\>/.freeze

  included do
    def render_filled_template(template, context)
      return render json: {}, status: :not_found if template.nil?

      authorize template, :show?

      filled_template = build_document(template, context)

      response.headers['Content-Type'] = DOCX_MIME_TYPE
      send_data filled_template, type: DOCX_MIME_TYPE, status: :created
    end

    private

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
  end
end
