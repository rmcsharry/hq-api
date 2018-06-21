# frozen_string_literal: true

require 'devise/jwt/test_helpers'

RSpec.shared_examples 'authorization policy' do |roles, options|
  verb = options[:permitted] ? 'permits' : 'forbids'
  roles.each do |role|
    describe "#{verb} access" do
      let!(:current_user) do
        return permitted_user if options[:permitted] && defined?(permitted_user)
        create(:user, user_groups: [create(:user_group, roles: [role])])
      end
      let(:headers) { { 'Content-Type' => 'application/vnd.api+json' } }
      let(:auth_headers) { Devise::JWT::TestHelpers.auth_headers(headers, current_user) }

      before(:each) do
        endpoint.call(auth_headers)
      end

      it "by users whom`s sole role is #{role}", bullet: false do
        expect(response).not_to have_http_status(403) if options[:permitted]
        expect(response).to have_http_status(403) unless options[:permitted]
      end

      if options[:expectation]
        it 'fulfills additional expectation' do
          expect(options[:expectation].call(role, response)).to eq(true)
        end
      end
    end
  end
end
