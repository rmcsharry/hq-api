# frozen_string_literal: true

module Docx
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

        nodes_with_replace_tokens(document).each do |node|
          apply_context node, context
        end
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

    private

    # Find and return all nodes (not necessarily leafs) that contain at least
    # one token in the form of {.*}.
    def nodes_with_replace_tokens(document)
      nodes = document.xpath('//*[contains(text(), "{")]')
      nodes.map do |node|
        current_node = node
        current_node = current_node.parent while current_node.parent && !current_node.text.include?('}')

        current_node.text.match?(/{.*}/) ? current_node : nil
      end.compact
    end

    # Drill down into child text-nodes of given node and search
    # for token in the form of {.*}. For found token, erase their
    # container nodes contents and insert replacement from context
    # if that token can be found in it
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def apply_context(node, context)
      current_key = ''
      current_nodes = []
      node.search('text()').each do |text_node|
        current_key += text_node.text
        match = /\{(?<token>(.*))\}/.match(current_key)

        if match.nil?
          current_nodes << text_node
          next
        end

        key = match['token']
        pre_match = match.pre_match
        replacement = context.dig(*key.split('.').map(&:to_sym))
        text_node.content = "#{pre_match}#{replacement}"
        rest = match.post_match
        if rest.include?('{') || rest.include?('}')
          current_key = rest
        else
          text_node.content += rest
          current_key = ''
        end

        current_nodes.each do |clearable_node|
          clearable_node.content = ''
        end
        current_nodes = []
      end
    end
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
