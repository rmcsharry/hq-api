# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WhitelistedUrl do
  describe '#whitelisted_url?' do
    ENV['WHITELISTED_URLS'] = 'http://localhost:3001,https://app.dev.hqfinanz.de,https://www.hqtrust.de'

    context 'for whitelisted urls' do
      let(:urls) { %w[http://localhost:3001 http://localhost:3001/test/url https://app.dev.hqfinanz.de/] }

      it 'is true' do
        urls.each do |url|
          expect(described_class.whitelisted_url?(url: url)).to be true
        end
      end
    end

    context 'for not whitelisted urls' do
      let(:urls) { %w[http://localhost:8888 http://evil-domain.com/test/url http://app.dev.hqfinanz.de/] }

      it 'is false' do
        urls.each do |url|
          expect(described_class.whitelisted_url?(url: url)).to be false
        end
      end
    end
  end
end
