# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DecodeEWSIdTokenService, type: :service_object do
  subject { -> { DecodeEWSIdTokenService.call token } }

  let(:private_key) { OpenSSL::PKey::RSA.generate(2048) }
  let(:public_key) { private_key.public_key }

  let(:token_algorithm) { 'RS256' }
  let(:token_headers) { { x5t: 'ID6_Y31siXaJqK9oPRjUmJMC3yM' } }
  let(:valid_token_payload) do
    {
      'appctxsender' => '00000002-0000-0ff1-ce00-000000000000@vertical.root',
      'aud' => 'https://localhost:3002/index.html',
      'exp' => 1_534_258_438,
      'isbrowserhostedapp' => 'True',
      'iss' => '00000002-0000-0ff1-ce00-000000000000@vertical.root',
      'nbf' => 1_534_229_638,
      'appctx' => <<~APPCTX
        {"msexchuid":"008c2269-2676-42a2-9f5d-d2e60ed85b28","version":"ExIdTok.V1","amurl":"https://outlook.onvertical.com:443/autodiscover/metadata/json/1"}
      APPCTX
    }
  end
  let(:token_payload) { valid_token_payload }
  let(:token) { JWT.encode(token_payload, private_key, token_algorithm, token_headers) }

  before do
    Timecop.freeze(Time.zone.local(2018, 8, 14, 12))

    allow(ENV).to receive(:[]).with('EWS_AUTH_PUBLIC_KEY').and_return(public_key.to_s)
    allow(ENV).to receive(:[]).with('OUTLOOK_ORIGINS').and_return('localhost:3002')
  end

  after do
    Timecop.return
  end

  describe 'valid id token parameters and payload' do
    it 'is decoded correctly' do
      expect(subject.call).to eq(valid_token_payload)
    end
  end

  describe 'token with missing x5t header' do
    let(:token_headers) { { x4t: 'incorrect-header' } }

    it 'is rejected' do
      expect do
        subject.call
      end.to raise_error(JWT::VerificationError)
    end
  end

  describe 'token not using RS256 algorithm' do
    let(:token_algorithm) { 'RS384' }

    it 'is rejected' do
      expect do
        subject.call
      end.to raise_error(JWT::IncorrectAlgorithm)
    end
  end

  describe 'time constraints' do
    it 'respects nbf' do
      Timecop.freeze(Time.zone.local(2018, 8, 13))

      expect do
        subject.call
      end.to raise_error(JWT::ImmatureSignature)
    end

    it 'respects exp' do
      Timecop.freeze(Time.zone.local(2018, 8, 15))

      expect do
        subject.call
      end.to raise_error(JWT::ExpiredSignature)
    end

    it 'accepts valid point in time between nbf and exp' do
      Timecop.freeze(Time.zone.local(2018, 8, 14, 12))

      expect(subject.call).to eq(valid_token_payload)
    end
  end

  describe 'invalid aud' do
    let(:token_payload) do
      valid_token_payload.merge(
        'aud' => 'https://localhost:8888/index.html'
      )
    end

    it 'is rejected' do
      expect do
        subject.call
      end.to raise_error(JWT::InvalidAudError)
    end
  end

  describe 'invalid appctx#version' do
    let(:token_payload) do
      valid_token_payload.merge(
        'appctx' => <<~APPCTX
          {"msexchuid":"008c2269-2676-42a2-9f5d-d2e60ed85b28","version":"ExIdTok.V2","amurl":"https://outlook.onvertical.com:443/autodiscover/metadata/json/1"}
        APPCTX
      )
    end

    it 'is rejected' do
      expect do
        subject.call
      end.to raise_error(JWT::InvalidPayload)
    end
  end

  describe 'invalid appctx#amurl' do
    let(:token_payload) do
      valid_token_payload.merge(
        'appctx' => <<~APPCTX
          {"msexchuid":"008c2269-2676-42a2-9f5d-d2e60ed85b28","version":"ExIdTok.V1","amurl":"invalid-url"}
        APPCTX
      )
    end

    it 'is rejected' do
      expect do
        subject.call
      end.to raise_error(JWT::InvalidPayload)
    end
  end

  describe 'invalid signature' do
    let(:unknown_private_key) { OpenSSL::PKey::RSA.generate(2048) }
    let(:token) { JWT.encode(token_payload, unknown_private_key, token_algorithm, token_headers) }

    it 'is rejected' do
      expect do
        subject.call
      end.to raise_error(JWT::VerificationError)
    end
  end
end
