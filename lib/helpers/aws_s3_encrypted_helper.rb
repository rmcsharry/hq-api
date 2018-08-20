# frozen_string_literal: true

# Helper to interact with encrypted files on S3
module AwsS3EncryptedHelper
  def s3_resource
    Aws::S3::Resource.new(
      access_key_id: Rails.application.secrets.aws_s3_access_key_id,
      secret_access_key: Rails.application.secrets.aws_s3_secret_access_key,
      region: ENV['AWS_REGION']
    )
  end

  def download_decrypted_s3_file(s3_key:)
    # Different environments require different kinds of escaping line breaks
    private_key = ENV['AWS_S3_ENCRYPTION_PRIVATE_KEY'].gsub('\\\\n', "\n").gsub('\\n', "\n")
    decryption_key = OpenSSL::PKey::RSA.new(private_key, ENV['AWS_S3_ENCRYPTION_PASSPHRASE'])
    enc_client = Aws::S3::Encryption::Client.new(client: s3_resource.client, encryption_key: decryption_key)

    enc_client.get_object(bucket: ENV['AWS_S3_BUCKET_NAME'], key: s3_key)
  end

  def decrypted_s3_tempfile(s3_key:)
    resp = download_decrypted_s3_file(s3_key: s3_key)
    file = Tempfile.new
    file.binmode
    file.write(resp.body.read)
    file.read
    file
  end
end
