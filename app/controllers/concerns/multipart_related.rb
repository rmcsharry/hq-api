# frozen_string_literal: true

require 'active_support/concern'

# Adds capability to support multipart/related POST requests
module MultipartRelated
  extend ActiveSupport::Concern

  MULTIFORM_TYPE = 'multipart/related'

  included do
    # rubocop:disable Rails/LexicallyScopedActionFilter
    before_action :parse_multipart_params, only: :create
    # rubocop:enable Rails/LexicallyScopedActionFilter

    private

    def verify_content_type_header
      return true if params[:action] == 'create' && request.content_type == MULTIFORM_TYPE
      super
    end

    def parse_multipart_params
      return unless params[:data].is_a?(String)

      data = ActionController::Parameters.new(JSON.parse(params[:data]))
      replace_file_references(data)
    end

    def replace_file_references(data)
      if !data.dig(:attributes, :documents).nil?
        data[:attributes][:documents]&.each do |document|
          fetch_file_reference(document)
        end
      elsif !data.dig(:attributes, :file).nil?
        fetch_file_reference(data[:attributes])
      end

      params[:data] = data
    end

    def fetch_file_reference(container)
      ref = container[:file][/^cid:(.+)$/ni, 1]
      container[:file] = params[ref]
    end
  end
end
