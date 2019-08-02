# frozen_string_literal: true

module Quill
  # Defines an interface to parse QuillDelta
  # Documentation: https://quilljs.com/docs/delta/#delta
  class Delta
    def initialize(delta_string, justify_content = false)
      @delta_string = delta_string
      @justify_content = justify_content
    end

    def to_s
      parsed_delta
    end

    private

    def parsed_delta
      parse JSON.parse(@delta_string)
    rescue JSON::ParserError => _e # rubocop:disable Naming/RescuedExceptionsVariableName until v0.67.3
      @delta_string
    end

    def parse(delta_object)
      @paragraphs = [Quill::Paragraph.new(nil, @justify_content)]

      delta_object['ops']&.each do |insertion|
        insert = insertion['insert']
        attributes = insertion['attributes']

        # Insert exactly equal to "\n" implies line-format for the current paragraph
        # Reference: https://quilljs.com/docs/delta/#line-formatting
        next apply_line_format(attributes) if insert == "\n"

        apply_insert insert, attributes
      end

      # Quill does always end with a new line which we strip here
      @paragraphs[0..-2].map(&:to_s).join
    end

    # Set line-format for current paragraph
    def apply_line_format(attributes)
      @paragraphs.last.attributes = attributes
      @paragraphs << Quill::Paragraph.new(nil, @justify_content)
    end

    # Insert given text into current paragraph.
    # Insert a new paragraph for every new line, delimited by "\n".
    # rubocop:disable Metrics/AbcSize
    def apply_insert(insert, attributes)
      insert.lines.each do |line|
        text_before_newline = line.split("\n")

        unless text_before_newline.first.nil?
          @paragraphs.last.text_runs << Quill::TextRun.new(text_before_newline.first, attributes)
        end

        line.scan("\n").count.times do
          @paragraphs << Quill::Paragraph.new(nil, @justify_content)
        end
      end
    end
    # rubocop:enable Metrics/AbcSize
  end

  # Defines text-paragraphs consisting of multiple formatted text-fragments.
  # Paragraphs can be formatted via attributes.
  class Paragraph
    attr_accessor :attributes
    attr_reader :text_runs

    def initialize(text_run = nil, justify_content = false)
      @text_runs = [text_run].compact
      @justify_content = justify_content
    end

    def to_s
      text_runs = @text_runs.map(&:to_s)
      "<w:p>#{justify_content_tag}#{attribute_tag}#{text_runs.join}</w:p>"
    end

    private

    def justify_content_tag
      return nil unless @justify_content

      "<w:pPr><w:jc w:val='both'/><w:spacing w:before='270' w:after='270' w:line='270' w:lineRule='exact' /></w:pPr>"
    end

    def attribute_tag
      return nil if @attributes.nil?

      "<w:pPr>#{style_tags.join}</w:pPr>"
    end

    def style_tags
      @attributes.map do |key, value|
        next unless key == 'list' && value == 'bullet'

        <<-TAG.squish
          <w:numPr>
            <w:ilvl w:val="0"/>
            <w:numId w:val="1"/>
          </w:numPr>
        TAG
      end
    end
  end

  # Defines text-fragments with formatting specified by attributes
  class TextRun
    attr_reader :attributes
    attr_reader :text

    def initialize(text = '', attributes = nil)
      @attributes = attributes
      @text = text
    end

    def to_s
      "<w:r>#{attribute_tag}<w:t xml:space=\"preserve\">#{@text.gsub('&', '&amp;')}</w:t></w:r>"
    end

    private

    STYLE_TAG_MAP = {
      bold: '<w:b/>',
      italic: '<w:i/>'
    }.freeze

    def attribute_tag
      return nil if @attributes.nil?

      "<w:rPr>#{style_tags.join}</w:rPr>"
    end

    def style_tags
      @attributes.map do |key, is_enabled|
        next unless is_enabled

        STYLE_TAG_MAP[key.to_sym]
      end
    end
  end
end
