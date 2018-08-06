# frozen_string_literal: true

require 'helpers/aws_s3_encrypted_helper'

# rubocop:disable Metrics/BlockLength
namespace :data_import do
  include AwsS3EncryptedHelper

  desc 'Upload file to S3 (with client-side encryption)'
  task :upload_file, %i[file bucket s3_key key_file] => [:environment] do |_task, args|
    file = args[:file]
    bucket = args[:bucket]
    s3_key = args[:s3_key]
    key_file = args[:key_file]

    public_key = File.read(key_file)
    key = OpenSSL::PKey::RSA.new(public_key)

    enc_client = Aws::S3::Encryption::Client.new(client: s3_resource.client, encryption_key: key)

    upload_encrypted_item(enc_client: enc_client, file: file, bucket: bucket, s3_key: s3_key)
  end

  desc 'Upload folder to S3 (with client-side encryption)'
  task :upload_folder, %i[folder bucket s3_key key_file] => [:environment] do |_task, args|
    folder = args[:folder]
    bucket = args[:bucket]
    s3_key = args[:s3_key]
    key_file = args[:key_file]

    public_key = File.read(key_file)
    key = OpenSSL::PKey::RSA.new(public_key)

    enc_client = Aws::S3::Encryption::Client.new(client: s3_resource.client, encryption_key: key)

    Dir.foreach(folder) do |item|
      next if ['.', '..', '.DS_Store'].include?(item)

      upload_encrypted_item(
        enc_client: enc_client, file: "#{folder}/#{item}", bucket: bucket, s3_key: "#{s3_key}/#{item}"
      )
    end
  end
end
# rubocop:enable Metrics/BlockLength

def upload_encrypted_item(enc_client:, file:, bucket:, s3_key:)
  # Add encrypted item to bucket
  enc_client.put_object(
    body: File.read(file),
    bucket: bucket,
    key: s3_key
  )

  puts "Added #{s3_key} to bucket #{bucket}."
end
