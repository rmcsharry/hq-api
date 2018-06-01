# frozen_string_literal: true

# Check if a given URL is whitelisted
module WhitelistedUrl
  # Raises an error if the given URL is not whitelisted
  # @param key [String] name of the url field
  # @param url [String] URL that needs to be checked
  # @return [void]
  def check_whitelisted_url!(key: 'url', url:)
    raise JSONAPI::Exceptions::InvalidFieldValue.new(key, url) unless WhitelistedUrl.whitelisted_url?(url: url)
  end

  # Validates if the given URL is whitelisted
  # @return [Boolean]
  def self.whitelisted_url?(url:)
    uri = URI.parse(url)
    whitelisted_urls = ENV['WHITELISTED_URLS'].split(',')
    whitelisted_urls.any? do |whitelisted_url|
      whitelisted_uri = URI.parse(whitelisted_url)
      uri.scheme == whitelisted_uri.scheme && uri.host == whitelisted_uri.host && uri.port == whitelisted_uri.port
    end
  end
end
