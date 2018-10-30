# frozen_string_literal: true

RSpec.shared_examples 'request for ews authenticated user' do |options|
  verb = options[:permitted] ? 'permitted' : 'forbidden'
  describe 'is' do
    let!(:user) do
      user = create(:user, user_groups: [create(:user_group, roles: UserGroup::AVAILABLE_ROLES)])
      user.authenticated_via_ews = true
      user
    end
    let(:headers) { { 'Content-Type' => 'application/vnd.api+json' } }
    let(:auth_headers) { Devise::JWT::TestHelpers.auth_headers(headers, user) }

    before(:each) do
      endpoint.call(auth_headers)
    end

    it verb, bullet: false do
      expect(response).not_to have_http_status(403) if options[:permitted]
      expect(response).to have_http_status(403) unless options[:permitted]
    end
  end
end

RSpec.shared_examples 'forbid access for ews authenticated users' do |endpoint, options|
  resource = options[:resource]

  context resource do
    describe '#index' do
      let(:endpoint) { ->(auth_headers) { get endpoint, headers: auth_headers } }

      include_examples 'request for ews authenticated user', permitted: options[:except]&.include?(:index)
    end

    describe '#show' do
      let(:endpoint) { ->(auth_headers) { get "#{endpoint}/#{record.id}", headers: auth_headers } }

      include_examples 'request for ews authenticated user', permitted: options[:except]&.include?(:show)
    end

    describe '#create' do
      let(:endpoint) { ->(auth_headers) { post endpoint, params: payload.to_json, headers: auth_headers } }
      let(:payload) do
        { data: { type: resource } }
      end

      include_examples 'request for ews authenticated user', permitted: options[:except]&.include?(:create)
    end

    describe '#update' do
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

      include_examples 'request for ews authenticated user', permitted: options[:except]&.include?(:update)
    end

    describe '#destroy' do
      let(:endpoint) { ->(auth_headers) { delete "#{endpoint}/#{record.id}", headers: auth_headers } }

      include_examples 'request for ews authenticated user', permitted: options[:except]&.include?(:destroy)
    end
  end
end
