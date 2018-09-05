# frozen_string_literal: true

require 'helpers/aws_s3_encrypted_helper'

namespace :db do
  include AwsS3EncryptedHelper

  desc 'Generate database dump and store on S3'
  task archive_backup: :environment do
    db = ActiveRecord::Base.connection_config
    file_name = "db_dump_#{Time.now.utc.strftime('%Y%m%d_%H%M%S')}.sql"
    file = Rails.root.join('db', 'backups', file_name)
    cmd = "pg_dump -F c -v --dbname=postgresql://#{db[:username]}:#{db[:password]}@#{db[:host]}/#{db[:database]} | " \
      "gzip > #{file}"
    puts cmd
    system cmd

    key = OpenSSL::PKey::RSA.new(ENV['AWS_S3_ENCRYPTION_PUBLIC_KEY'].gsub('\\\\n', "\n").gsub('\\n', "\n"))
    enc_client = Aws::S3::Encryption::Client.new(client: s3_resource.client, encryption_key: key)
    upload_encrypted_item(
      enc_client: enc_client, file: file, bucket: ENV['AWS_S3_BACKUPS_BUCKET_NAME'], s3_key: "db_backups/#{file_name}"
    )
  end
end

def upload_encrypted_item(enc_client:, file:, bucket:, s3_key:)
  # Add encrypted item to bucket
  enc_client.put_object(
    body: File.read(file),
    bucket: bucket,
    key: s3_key
  )

  puts "Added #{s3_key} to bucket #{bucket}."
end
