# frozen_string_literal: true

# Defines module for interacting with .docx files
module Docx
  MIME_TYPE = Mime[:docx].to_s.freeze

  class RenderError < StandardError; end

  def self.docx?(file)
    file.content_type == Docx::MIME_TYPE
  end

  # Defines an interface to read and write .docx files
  class Document
    attr_reader :documents

    def initialize(tempfile)
      @tempfile = tempfile
      @documents = {}
    end

    def commit(context)
      tempfile = Tempfile.new
      Sablon.template(@tempfile.path).render_to_file(tempfile.path, context)
      @tempfile = tempfile
    rescue Sablon::TemplateError, Sablon::ContextError => e
      raise Docx::RenderError, e.message
    rescue NoMethodError => e
      raise Docx::RenderError, "Failed executing operation: #{e.message}"
    end

    def to_s
      parse_document!
      @documents.map do |_file_name, document|
        document.text if document.instance_of? Nokogiri::XML::Document
      end.compact.join("\n")
    end

    def render
      parse_document!
      reset_settings!
      Zip::OutputStream.write_buffer do |out|
        generate_output_file(out, @documents)
      end.string
    end

    def reset_settings!
      settings_document = @documents['word/settings.xml']
      zoom_node = settings_document&.xpath('//w:zoom')&.first
      zoom_node&.set_attribute('w:percent', '100')
    end

    # Find all files in the zipped directory and put them
    # into a hash
    def parse_document!
      Zip::File.open(@tempfile.path) do |zip_file|
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
