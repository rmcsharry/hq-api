# frozen_string_literal: false

require 'active_support/concern'

# Adds capability to build documents from templates and data
module DocumentBuilder
  extend ActiveSupport::Concern

  DOCX_MIME_TYPE = Mime[:docx].to_s.freeze
  XML_TAG = /\<[^\>]+\>/.freeze

  # rubocop:disable Metrics/BlockLength
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
        xml_gsub!(document, "{#{key}}", value)
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

    def xml_gsub!(document, pattern, replacement)
      document_content = document.instance_variable_get(:@document_content)
      regexp, tags_pattern = build_xml_matchers(pattern, replacement)
      document_content.gsub!(regexp, tags_pattern)
    end

    # rubocop:disable Metrics/MethodLength
    def build_xml_matchers(pattern, replacement)
      replacement = replacement.to_s.encode(xml: :text)
      regexp = //
      tags_pattern = ''

      pattern.to_s.each_char.each_with_index do |char, i|
        escaped_char = Regexp.quote(char)
        regexp = /#{regexp}(?<tag#{i}>(#{XML_TAG})*)#{escaped_char}/
        tags_pattern << '\k<tag' + i.to_s + '>'
        tags_pattern << replacement if i.zero?
      end

      tags_pattern.force_encoding('ASCII-8BIT')
      [regexp, tags_pattern]
    end
    # rubocop:enable Metrics/MethodLength
  end
  # rubocop:enable Metrics/BlockLength
end
