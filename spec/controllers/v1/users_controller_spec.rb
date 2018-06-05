# frozen_string_literal: true

require 'rails_helper'
require 'devise/jwt/test_helpers'

USERS_ENDPOINT = '/v1/users'

RSpec.describe USERS_ENDPOINT, type: :request do
  let(:headers) { { 'Content-Type' => 'application/vnd.api+json' } }
  let!(:user) { create(:user) }
  let(:auth_headers) { Devise::JWT::TestHelpers.auth_headers(headers, user) }

  describe 'POST /v1/users/invite' do
    let(:email) { 'test@hqfinanz.de' }
    let(:user_group1) { create(:user_group) }
    let(:user_group2) { create(:user_group) }
    let(:contact) { create(:contact_person) }
    subject { -> { post("#{USERS_ENDPOINT}/invite", params: payload.to_json, headers: auth_headers) } }

    context 'with valid payload' do
      let(:payload) do
        {
          data: {
            type: 'users',
            attributes: {
              email: email,
              set_password_url: set_password_url
            },
            relationships: {
              'contact': {
                data: { id: contact.id, type: 'contacts' }
              },
              'user-groups': {
                data: [
                  { id: user_group1.id, type: 'user-groups' },
                  { id: user_group2.id, type: 'user-groups' }
                ]
              }
            }
          }
        }
      end

      context 'with set password url' do
        let(:set_password_url) { 'http://localhost:3001/password/set-initial' }

        it 'invites a new user' do
          is_expected.to change(User, :count).by(1)
          expect(response).to have_http_status(202)
          user = User.find_by(email: email)
          expect(ActionMailer::Base.deliveries.last.header['set-password-url'].value).to eq set_password_url
          expect(user.contact).to eq contact
          expect(user.user_groups).to include(user_group1, user_group2)
        end
      end

      context 'and no set password url' do
        let(:set_password_url) { nil }

        it 'does not create a new user' do
          is_expected.to change(User, :count).by(0)
          expect(response).to have_http_status(400)
          expect(JSON.parse(response.body)['errors'].first['detail']).to eq(
            'The required parameter, set_password_url, is missing.'
          )
        end
      end

      context 'and evil set password url' do
        let(:set_password_url) { 'http://evil-domain.com/phish-password' }

        it 'does not create a new user' do
          is_expected.to change(User, :count).by(0)
          expect(response).to have_http_status(400)
          expect(JSON.parse(response.body)['errors'].first['detail']).to eq(
            'http://evil-domain.com/phish-password is not a valid value for set_password_url.'
          )
        end
      end
    end

    context 'without contact' do
      let(:payload) do
        {
          data: {
            type: 'users',
            attributes: {
              email: email
            },
            relationships: {
              'user-groups': {
                data: [
                  { id: user_group1.id, type: 'user-groups' },
                  { id: user_group2.id, type: 'user-groups' }
                ]
              }
            }
          }
        }
      end

      it 'does not create a new user' do
        is_expected.to change(User, :count).by(0)
        expect(response).to have_http_status(400)
        expect(JSON.parse(response.body)['errors'].first['detail']).to eq 'The required parameter, contact, is missing.'
      end
    end
  end

  describe 'GET /v1/users/invitation/<invitation_token>' do
    let(:contact) { create(:contact_person) }
    let(:email) { 'invited@hqfinanz.de' }
    let(:user) { User.invite!(email: email, contact: contact) }

    context 'with correct invitation token' do
      it 'returns the invited user\'s email' do
        get("#{USERS_ENDPOINT}/invitation/#{user.raw_invitation_token}", params: {}, headers: headers)
        expect(response).to have_http_status(200)
        body = JSON.parse(response.body)
        expect(body.keys).to include 'data'
        expect(body['data']['attributes']['email']).to eq email
      end
    end

    context 'with correct invitation token after the invitation has been accetped' do
      before do
        user.accept_invitation!
      end

      it 'returns an error' do
        get("#{USERS_ENDPOINT}/invitation/#{user.raw_invitation_token}", params: {}, headers: headers)
        expect(response).to have_http_status(404)
        body = JSON.parse(response.body)
        expect(body['errors'].first['title']).to eq 'Record not found'
        expect(body['errors'].first['detail']).to eq(
          "The record identified by #{user.raw_invitation_token} could not be found."
        )
      end
    end

    context 'with incorrect invitation token' do
      it 'returns an error' do
        get("#{USERS_ENDPOINT}/invitation/asdf", params: {}, headers: headers)
        expect(response).to have_http_status(404)
        body = JSON.parse(response.body)
        expect(body['errors'].first['title']).to eq 'Record not found'
        expect(body['errors'].first['detail']).to eq 'The record identified by asdf could not be found.'
      end
    end
  end

  describe 'POST /v1/users/invitation/<invitation_token>' do
    let(:contact) { create(:contact_person) }
    let(:email) { 'invited@hqfinanz.de' }
    let(:user) { User.invite!(email: email, contact: contact) }
    let(:payload) do
      {
        data: {
          type: 'users',
          attributes: {
            email: email,
            password: 'testmctest1A!'
          }
        }
      }
    end

    context 'with correct invitation token' do
      it 'accepts the invitation and returns the invited user' do
        post("#{USERS_ENDPOINT}/invitation/#{user.raw_invitation_token}", params: payload.to_json, headers: headers)
        expect(response).to have_http_status(200)
        body = JSON.parse(response.body)
        expect(body.keys).to include 'data'
        expect(body['data']['attributes']['email']).to eq email
        expect(user.reload.invitation_accepted?).to be true
      end
    end

    context 'with correct invitation token after the invitation has been accetped' do
      before do
        user.accept_invitation!
      end

      it 'returns an error' do
        post("#{USERS_ENDPOINT}/invitation/#{user.raw_invitation_token}", params: payload.to_json, headers: headers)
        expect(response).to have_http_status(404)
        body = JSON.parse(response.body)
        expect(body['errors'].first['title']).to eq 'Record not found'
        expect(body['errors'].first['detail']).to eq(
          "The record identified by #{user.raw_invitation_token} could not be found."
        )
      end
    end

    context 'with incorrect invitation token' do
      it 'returns an error' do
        post("#{USERS_ENDPOINT}/invitation/asdf", params: payload.to_json, headers: headers)
        expect(response).to have_http_status(404)
        body = JSON.parse(response.body)
        expect(body['errors'].first['title']).to eq 'Record not found'
        expect(body['errors'].first['detail']).to eq 'The record identified by asdf could not be found.'
      end
    end
  end

  describe 'GET /v1/users/<user_id>' do
    let!(:user) { create(:user, email: email) }
    let(:auth_headers) { Devise::JWT::TestHelpers.auth_headers(headers, user) }
    let(:email) { 'test@hqfinanz.de' }

    it 'gets a single user without updating sign in count' do
      expect(user.sign_in_count).to eq 0
      get("#{USERS_ENDPOINT}/#{user.id}", params: {}, headers: auth_headers)
      expect(user.reload.sign_in_count).to eq 0
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body.keys).to include 'data', 'meta'
      expect(body['data']['attributes']['email']).to eq email
    end
  end

  describe 'POST /v1/users/reset-password' do
    let(:email) { 'user@hqfinanz.de' }
    let(:reset_password_url) { 'http://localhost:3001/password/set' }
    let!(:user) { create(:user, email: email) }
    let(:reset_email) { email }
    let(:payload) do
      {
        data: {
          type: 'users',
          attributes: {
            email: reset_email,
            reset_password_url: reset_password_url
          }
        }
      }
    end

    context 'with regular reset password url and email' do
      it 'responds with 202 and triggers a reset' do
        post("#{USERS_ENDPOINT}/reset-password", params: payload.to_json, headers: headers)
        expect(response).to have_http_status(202)
        expect(response.body).to eq '{}'
        expect(ActionMailer::Base.deliveries.last.header['reset-password-url'].value).to eq reset_password_url
      end
    end

    context 'with upcase email that exists' do
      let(:reset_email) { 'USER@hqfinanz.de' }

      it 'responds with 202' do
        post("#{USERS_ENDPOINT}/reset-password", params: payload.to_json, headers: headers)
        expect(response).to have_http_status(202)
        expect(response.body).to eq '{}'
        expect(ActionMailer::Base.deliveries.last.header['reset-password-url'].value).to eq reset_password_url
      end
    end

    context 'with email that does not exist' do
      let(:reset_email) { 'no_user@hqfinanz.de' }

      it 'responds with 202' do
        post("#{USERS_ENDPOINT}/reset-password", params: payload.to_json, headers: headers)
        expect(response).to have_http_status(202)
        expect(response.body).to eq '{}'
        expect(ActionMailer::Base.deliveries).to be_empty
      end
    end

    context 'and no reset password url' do
      let(:reset_password_url) { nil }

      it 'does not trigger a reset' do
        post("#{USERS_ENDPOINT}/reset-password", params: payload.to_json, headers: headers)
        expect(response).to have_http_status(400)
        expect(JSON.parse(response.body)['errors'].first['detail']).to eq(
          'The required parameter, reset_password_url, is missing.'
        )
      end
    end

    context 'and evil reset password url' do
      let(:reset_password_url) { 'http://evil-domain.com/phish-password' }

      it 'does not trigger a reset' do
        post("#{USERS_ENDPOINT}/reset-password", params: payload.to_json, headers: headers)
        expect(response).to have_http_status(400)
        expect(JSON.parse(response.body)['errors'].first['detail']).to eq(
          'http://evil-domain.com/phish-password is not a valid value for reset_password_url.'
        )
      end
    end
  end

  describe 'POST /v1/users/set-password' do
    let(:payload) do
      {
        data: {
          type: 'users',
          attributes: {
            password: password
          }
        }
      }
    end

    context 'with a valid password' do
      let(:password) { 'testmctest2A!' }
      it 'responds with 202 and updates the password' do
        old_password = user.encrypted_password
        post("#{USERS_ENDPOINT}/set-password", params: payload.to_json, headers: auth_headers)
        expect(response).to have_http_status(202)
        expect(response.body).to eq '{}'
        expect(user.reload.encrypted_password).to_not eq old_password
      end
    end

    context 'with an invalid password' do
      let(:password) { 'testmctest' }
      it 'responds with 400 and does not update the password' do
        old_password = user.encrypted_password
        post("#{USERS_ENDPOINT}/set-password", params: payload.to_json, headers: auth_headers)
        expect(response).to have_http_status(422)
        expect(JSON.parse(response.body)['errors'].first['detail']).to eq(
          'password - Ihr Passwort ist nicht sicher genug. Bitte verwenden Sie mindestens ein Sonderzeichen, eine ' \
          'Zahl sowie Groß- und Kleinbuchstaben. Das Passwort muss eine Gesamtlämnge von mindestens 10 Zeichen haben.'
        )
        expect(user.reload.encrypted_password).to eq old_password
      end
    end
  end

  describe 'POST /v1/users/set-password/<reset_password_token>' do
    let(:token) { user.send(:set_reset_password_token) }
    let(:password) { 'testmctest2A!' }
    let(:payload) do
      {
        data: {
          type: 'users',
          attributes: {
            password: password
          }
        }
      }
    end

    context 'with a valid password' do
      it 'responds with 202 and updates the password' do
        old_password = user.encrypted_password
        post("#{USERS_ENDPOINT}/set-password/#{token}", params: payload.to_json, headers: headers)
        expect(response).to have_http_status(200)
        expect(response.body).to eq '{}'
        expect(user.reload.encrypted_password).to_not eq old_password
      end
    end

    context 'with an invalid token' do
      it 'responds with 202 and updates the password' do
        old_password = user.encrypted_password
        post("#{USERS_ENDPOINT}/set-password/asdf", params: payload.to_json, headers: headers)
        expect(response).to have_http_status(404)
        body = JSON.parse(response.body)
        expect(body['errors'].first['title']).to eq 'Record not found'
        expect(body['errors'].first['detail']).to eq(
          'The record identified by asdf could not be found.'
        )
        expect(user.reload.encrypted_password).to eq old_password
      end
    end

    context 'with an invalid password' do
      let(:password) { 'testmctest' }
      it 'responds with 400 and does not update the password' do
        old_password = user.encrypted_password
        post("#{USERS_ENDPOINT}/set-password/#{token}", params: payload.to_json, headers: headers)
        expect(response).to have_http_status(422)
        expect(JSON.parse(response.body)['errors'].first['detail']).to eq(
          'password - Ihr Passwort ist nicht sicher genug. Bitte verwenden Sie mindestens ein Sonderzeichen, eine ' \
          'Zahl sowie Groß- und Kleinbuchstaben. Das Passwort muss eine Gesamtlämnge von mindestens 10 Zeichen haben.'
        )
        expect(user.reload.encrypted_password).to eq old_password
      end
    end
  end
end
