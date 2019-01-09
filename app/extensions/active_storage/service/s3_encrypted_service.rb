# frozen_string_literal: true

require 'aws-sdk-s3'
require 'active_support/core_ext/numeric/bytes'

module ActiveStorage
  class Service
    # Wraps the Amazon Simple Storage Service (S3) as an Active Storage service.
    # See ActiveStorage::Service for the generic API documentation that applies to all services.
    class S3EncryptedService < Service
      attr_reader :resource, :bucket, :upload_options, :encryption_client, :decryption_client

      def initialize(bucket:, upload: {}, encryption: {}, **options)
        @resource = Aws::S3::Resource.new(options)
        client = resource.client
        @bucket = bucket
        encryption_key = OpenSSL::PKey::RSA.new(encryption[:public_key].gsub('\\n', "\n"))
        decryption_key = OpenSSL::PKey::RSA.new(encryption[:private_key].gsub('\\n', "\n"), encryption[:passphrase])
        @encryption_client = Aws::S3::Encryption::Client.new(client: client, encryption_key: encryption_key)
        @decryption_client = Aws::S3::Encryption::Client.new(client: client, encryption_key: decryption_key)

        @upload_options = upload
      end

      def upload(key, io, checksum: nil, **)
        instrument :upload, key: key, checksum: checksum do
          begin
            encryption_client.put_object(
              upload_options.merge(body: io, bucket: bucket, content_md5: checksum, key: key)
            )
          rescue Aws::S3::Errors::BadDigest
            raise ActiveStorage::IntegrityError
          end
        end
      end

      def download(key)
        instrument :download, key: key do
          decrypted_object_for(key).body.string.force_encoding(Encoding::BINARY)
        end
      end

      def download_chunk(key, _range)
        # download in chunks is not supported as AWS SDK S3 currently does not support `:range`
        # (https://github.com/aws/aws-sdk-ruby/blob/63e7238a69509e3afe46ae2caa947545f6a76ce6/gems/aws-sdk-s3/lib/aws-sdk-s3/encryption/client.rb#L271)
        download(key)
      end

      def delete(key)
        instrument :delete, key: key do
          object_for(key).delete
        end
      end

      def delete_prefixed(prefix)
        instrument :delete_prefixed, prefix: prefix do
          resource.bucket(bucket).objects(prefix: prefix).batch_delete!
        end
      end

      def exist?(key)
        instrument :exist, key: key do |payload|
          answer = object_for(key).exists?
          payload[:exist] = answer
          answer
        end
      end

      def url(key, expires_in:, filename:, disposition:, content_type:)
        instrument :url, key: key do |payload|
          generated_url = object_for(key).presigned_url(
            :get,
            expires_in: expires_in.to_i,
            response_content_disposition: content_disposition_with(type: disposition, filename: filename),
            response_content_type: content_type
          )

          payload[:url] = generated_url

          generated_url
        end
      end

      # rubocop:disable Metrics/MethodLength
      def url_for_direct_upload(key, expires_in:, content_type:, content_length:, checksum:)
        instrument :url, key: key do |payload|
          generated_url = object_for(key).presigned_url(
            :put,
            expires_in: expires_in.to_i,
            content_type: content_type,
            content_length: content_length,
            content_md5: checksum
          )

          payload[:url] = generated_url

          generated_url
        end
      end
      # rubocop:enable Metrics/MethodLength

      def headers_for_direct_upload(_key, content_type:, checksum:, **)
        { 'Content-Type' => content_type, 'Content-MD5' => checksum }
      end

      private

      def decrypted_object_for(key)
        decryption_client.get_object(bucket: bucket, key: key)
      end

      def object_for(key)
        resource.bucket(bucket).object(key)
      end
    end
  end
end
