# frozen_string_literal: true

require 'rails_helper'
require 'devise/jwt/test_helpers'

USERS_ENDPOINT = '/v1/users'

RSpec.describe USERS_ENDPOINT, type: :request do
  let(:headers) { { 'Content-Type' => 'application/vnd.api+json' } }

  describe 'POST /v1/users/invite' do
    let!(:user) { create(:user) }
    let(:auth_headers) { Devise::JWT::TestHelpers.auth_headers(headers, user) }
    let(:email) { 'test@hqfinanz.de' }
    subject { -> { post("#{USERS_ENDPOINT}/invite", params: payload.to_json, headers: auth_headers) } }

    context 'with valid payload' do
      let(:user_group1) { create(:user_group) }
      let(:user_group2) { create(:user_group) }
      let(:contact) { create(:contact_person) }
      let(:payload) do
        {
          data: {
            type: 'users',
            attributes: {
              email: email
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

      it 'invites a new user' do
        is_expected.to change(User, :count).by(1)
        expect(response).to have_http_status(202)
        user = User.find_by(email: email)
        expect(user.contact).to eq contact
        expect(user.user_groups).to include(user_group1, user_group2)
      end
    end

    context 'without contact' do
      let(:user_group1) { create(:user_group) }
      let(:user_group2) { create(:user_group) }
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
        get("#{USERS_ENDPOINT}/invitation/#{user.raw_invitation_token}", headers: headers)
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
        get("#{USERS_ENDPOINT}/invitation/#{user.raw_invitation_token}", headers: headers)
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
        get("#{USERS_ENDPOINT}/invitation/asdf", headers: headers)
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
          password: 'testmctest1A!'
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

    it 'invites a new user' do
      expect(user.sign_in_count).to eq 0
      get("#{USERS_ENDPOINT}/#{user.id}", headers: auth_headers)
      expect(user.reload.sign_in_count).to eq 0
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body.keys).to include 'data', 'meta'
      expect(body['data']['attributes']['email']).to eq email
    end
  end
end
