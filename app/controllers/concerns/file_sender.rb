# frozen_string_literal: false

require 'active_support/concern'

# Adds capability to send files or archives of files
module FileSender
  extend ActiveSupport::Concern

  included do
    def send_archive(file_map, filename)
      archive = Zip::OutputStream.write_buffer do |out|
        file_map.each do |file_name, file|
          out.put_next_entry(file_name)
          out.write(file)
        end
      end.string

      send_data_with_name(archive, Mime[:zip].to_s, filename)
    end

    def send_attachment(file)
      send_data_with_name(file.download, file.content_type, file.filename)
    end

    private

    def send_data_with_name(data, content_type, filename)
      response.headers['Content-Type'] = content_type
      response.headers['Access-Control-Expose-Headers'] = 'Content-Disposition'
      send_data(data, filename: filename, status: :created, type: content_type)
    end
  end
end
