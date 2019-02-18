# frozen_string_literal: false

require 'active_support/concern'

# Adds capability to build documents from templates and data
module DocumentBuilder
  extend ActiveSupport::Concern

  # rubocop:disable Metrics/BlockLength
  included do
    def send_filled_template(template, context)
      authorize template, :show?

      file = template.file
      return send_file(file.download, file.content_type) unless Docx.docx?(file)

      filled_template = build_document(template, context)
      send_file(filled_template, Docx::MIME_TYPE)
    end

    def send_archive(file_map)
      archive = Zip::OutputStream.write_buffer do |out|
        file_map.each do |file_name, file|
          out.put_next_entry(file_name)
          out.write(file)
        end
      end.string

      send_file archive, Mime[:zip].to_s
    end

    def send_file(file, mime_type)
      response.headers['Content-Type'] = mime_type
      send_data file, type: mime_type, status: :created
    end

    def build_document(template, context)
      template_path = load_template(template).path
      document = Docx::Document.new(template_path)
      document.commit(context)
      document.render
    end

    private

    def load_template(template)
      tempfile = Tempfile.new
      tempfile.binmode
      tempfile.write template.file.download
      tempfile.close
      tempfile
    end
  end
  # rubocop:enable Metrics/BlockLength
end
