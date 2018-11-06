# frozen_string_literal: true

RSpec.shared_examples 'simple crud authorization' do |endpoint, options|
  resource = options[:resource]
  permissions = options[:permissions]
  skip = options[:skip] || []
  create_payload = options[:create_payload] || { data: { type: resource } }

  context "#{resource} (xlsx request)" do
    describe '#index' do
      break if skip.include? :index

      let(:endpoint) { ->(headers) { get endpoint, headers: xlsx_headers(headers) } }

      permit permissions[:export]
    end

    describe '#show' do
      break if skip.include? :show

      let(:endpoint) { ->(headers) { get "#{endpoint}/#{record.id}", headers: xlsx_headers(headers) } }

      permit permissions[:export]
    end

    describe '#create' do
      break if skip.include? :create

      let(:endpoint) { ->(headers) { post endpoint, params: payload.to_json, headers: xlsx_headers(headers) } }
      let(:payload) { create_payload }

      permit # none
    end

    describe '#update' do
      break if skip.include? :update

      let(:endpoint) do
        lambda do |headers|
          patch "#{endpoint}/#{record.id}", params: payload.to_json, headers: xlsx_headers(headers)
        end
      end
      let(:payload) do
        {
          data: {
            id: record.id,
            type: resource
          }
        }
      end

      permit # none
    end

    describe '#destroy' do
      break if skip.include? :destroy

      let(:endpoint) { ->(headers) { delete "#{endpoint}/#{record.id}", headers: xlsx_headers(headers) } }

      permit # none
    end
  end

  context "#{resource} (jsonapi request)" do
    describe '#index' do
      break if skip.include? :index

      let(:endpoint) { ->(auth_headers) { get endpoint, headers: auth_headers } }

      permit permissions[:read]
    end

    describe '#show' do
      break if skip.include? :show

      let(:endpoint) { ->(auth_headers) { get "#{endpoint}/#{record.id}", headers: auth_headers } }

      permit permissions[:read]
    end

    describe '#create' do
      break if skip.include? :create

      let(:endpoint) { ->(auth_headers) { post endpoint, params: payload.to_json, headers: auth_headers } }
      let(:payload) { create_payload }

      permit permissions[:write]
    end

    describe '#update' do
      break if skip.include? :update

      let(:endpoint) do
        lambda do |auth_headers|
          patch "#{endpoint}/#{record.id}", params: payload.to_json, headers: auth_headers
        end
      end
      let(:payload) do
        {
          data: {
            id: record.id,
            type: resource
          }
        }
      end

      permit permissions[:write]
    end

    describe '#destroy' do
      break if skip.include? :destroy

      let(:endpoint) { ->(auth_headers) { delete "#{endpoint}/#{record.id}", headers: auth_headers } }

      permit permissions[:destroy]
    end
  end
end
