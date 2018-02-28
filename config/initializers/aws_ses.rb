creds = Aws::Credentials.new(
  Rails.application.secrets.aws_ses_access_key_id,
  Rails.application.secrets.aws_ses_secret_access_key
)
Aws::Rails.add_action_mailer_delivery_method(:aws_sdk, credentials: creds, region: 'eu-west-1')
