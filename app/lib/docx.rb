# frozen_string_literal: true

# Defines module for interacting with .docx files
module Docx
  MIME_TYPE = Mime[:docx].to_s.freeze

  def self.docx?(file)
    file.content_type == Docx::MIME_TYPE
  end

  # Defines an interface to read and write .docx files
  class Document
    attr_reader :documents

    def initialize(path)
      @documents = {}

      parse_docx_file(path)
    end

    def commit(context)
      @documents.each do |_file_name, document|
        next unless document.instance_of? Nokogiri::XML::Document

        reset_settings!
        apply_context document.search('text()'), context
      end
    end

    def to_s
      @documents.map do |_file_name, document|
        document.text if document.instance_of? Nokogiri::XML::Document
      end.compact.join("\n")
    end

    def render
      Zip::OutputStream.write_buffer do |out|
        generate_output_file(out, @documents)
      end.string
    end

    def reset_settings!
      settings_document = @documents['word/settings.xml']
      zoom_node = settings_document&.xpath('//w:zoom')&.first
      zoom_node&.set_attribute('w:percent', '100')
    end

    # Drill down into child text-nodes of given node and search
    # for token in the form of {.*}. For found token, erase their
    # container nodes contents and insert replacement from context
    # if that token can be found in it
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def apply_context(text_nodes, context)
      current_key = ''
      current_nodes = []
      # rubocop:disable Metrics/BlockLength
      text_nodes.each do |text_node|
        current_key += text_node.text
        match = /\{(?<token>(.*))\}/.match(current_key)
        current_nodes << text_node

        next if match.nil?

        replacement = context.dig(*match['token'].split('.').map(&:to_sym))
        is_xml_replacement = replacement.to_s&.start_with?('<w:p>')

        # match_string is the token with the containing curlies, e.g. "{contact.name}"
        # the following loop iteratively deletes exactly the characters of said
        # match_string and inserts `replacement` when visiting the first character "{"
        match_string = match.to_s
        first_node = nil
        current_nodes.each do |intermediate_node|
          break if match_string.length.zero?

          intermediate_node.content = intermediate_node.content.chars.map do |char|
            if char != match_string[0] || match_string.length.zero?
              char
            else
              replaced_char = match_string[0]
              match_string[0] = ''
              if replaced_char == '{'
                first_node = intermediate_node
                is_xml_replacement ? '' : replacement
              end
            end
          end.join
        end

        if is_xml_replacement
          paragraph = first_node&.ancestors('//w:p')&.first
          paragraph&.replace(replacement)
        end

        current_key = text_node.text
        current_nodes = [text_node]
      end
      # rubocop:enable Metrics/BlockLength
    end
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize

    # Find all files in the zipped directory and put them
    # into a hash
    def parse_docx_file(path)
      Zip::File.open(path) do |zip_file|
        zip_file.each do |entry|
          next unless entry.file?

          content = entry.get_input_stream.read
          @documents[entry.name] = wrap_entry(entry.name, content)
        end
      end
    end

    # Determines how the content in the zip file entry should be wrapped
    def wrap_entry(entry_name, content)
      return content unless entry_name.match?(/\.(?:xml|rels)$/)

      Nokogiri::XML(content)
    end

    # IMPORTANT: Open Office does not ignore whitespace around tags.
    # We need to render the xml without indent and whitespace.
    def generate_output_file(zip_out, contents)
      # output entries to zip file
      created_dirs = []
      contents.each do |entry_name, content|
        create_dirs_in_zipfile(created_dirs, File.dirname(entry_name), zip_out)
        zip_out.put_next_entry(entry_name)
        # convert Nokogiri XML to string
        content = content.to_xml(indent: 0, save_with: 0) if content.instance_of?(Nokogiri::XML::Document)
        zip_out.write(content)
      end
    end

    # creates directories of the unzipped docx file in the newly created
    # docx file e.g. in case of word/_rels/document.xml.rels it creates
    # word/ and _rels directories to apply recursive zipping. This is a
    # hack to fix the issue of getting a corrupted file when any referencing
    # between the xml files happen like in the case of implementing hyperlinks.
    # The created_dirs array is augmented in place using '<<'
    def create_dirs_in_zipfile(created_dirs, entry_path, output_stream)
      entry_path_tokens = entry_path.split('/')
      return created_dirs unless entry_path_tokens.length > 1

      prev_dir = ''
      entry_path_tokens.each do |dir_name|
        prev_dir += dir_name + '/'
        next if created_dirs.include? prev_dir

        output_stream.put_next_entry(prev_dir)
        created_dirs << prev_dir
      end
    end
  end
end
