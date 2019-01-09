# frozen_string_literal: true

module ActiveStorage
  # Take a signed permanent reference for a blob and turn it into a data stream from an external storage.
  # Note: These URLs require an authentication header to be present.
  class BlobsController < ActionController::Base
    before_action :authenticate_user!
    include ActiveStorage::SetBlob

    def show
      expires_in ActiveStorage::Blob.service.url_expires_in
      send_data @blob.download, filename: @blob.filename.to_s
    end
  end
end
