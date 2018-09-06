# frozen_string_literal: true

require 'rails_helper'
require 'devise/jwt/test_helpers'

RSpec.describe 'authorization for', type: :request do
  context 'activities' do
    let!(:record) { create(:activity_note) }
    include_examples 'forbid access for ews authenticated users',
                     ACTIVITIES_ENDPOINT,
                     resource: 'activities',
                     except: [:create]
  end

  context 'activities' do
    let!(:permitted_mandate) { create(:mandate) }
    let!(:random_mandate) { create(:mandate) }
    let!(:contact) { create(:contact_person) }
    let!(:forbidden_mandate_activity) { create(:activity_note, mandates: [random_mandate]) }
    let!(:mandate_activity) { create(:activity_note, mandates: [permitted_mandate]) }
    let!(:contact_activity) { create(:activity_note, contacts: [contact]) }
    let!(:mandate_group) { create(:mandate_group, mandates: [permitted_mandate]) }
    let(:headers) { { 'Content-Type' => 'application/vnd.api+json' } }
    let(:auth_headers) { Devise::JWT::TestHelpers.auth_headers(headers, permitted_user) }

    def response_data
      JSON.parse(response.body)['data']
    end

    describe '#index' do
      let!(:permitted_user) { create(:user) }
      let(:endpoint) { ->(auth_headers) { get ACTIVITIES_ENDPOINT, headers: auth_headers } }

      it 'excludes activities that no permissions exist for' do
        endpoint.call(auth_headers)

        expect(response.status).to eq(403)
      end

      describe 'with mandates_read role' do
        let!(:user_group) do
          create(:user_group, users: [permitted_user], mandate_groups: [mandate_group], roles: [:mandates_read])
        end

        it 'includes activities for mandates which the user has permissions for' do
          endpoint.call(auth_headers)

          expect(Activity.count).to eq(3)
          expect(response_data.size).to eq(1)
        end
      end

      describe 'with contacts_read role' do
        let!(:user_group) do
          create(:user_group, users: [permitted_user], roles: [:contacts_read])
        end

        it 'includes activities for contacts' do
          endpoint.call(auth_headers)

          expect(Activity.count).to eq(3)
          expect(response_data.size).to eq(1)
        end
      end

      describe 'with contacts_read and mandates_read role' do
        let!(:user_group) do
          create(
            :user_group,
            users: [permitted_user],
            mandate_groups: [mandate_group],
            roles: %i[contacts_read mandates_read]
          )
        end

        it 'includes activities for contacts and permitted mandates' do
          endpoint.call(auth_headers)

          expect(Activity.count).to eq(3)
          expect(response_data.size).to eq(2)
        end
      end

      describe '(xlsx request)' do
        let(:endpoint) { ->(h) { get ACTIVITIES_ENDPOINT, headers: xlsx_headers(h) } }

        let!(:user_group) do
          create(:user_group, users: [permitted_user], roles: [:contacts_export])
        end

        permit :contacts_export, :mandates_export
      end
    end

    describe '#show' do
      let(:endpoint) do
        ->(auth_headers) { get "#{ACTIVITIES_ENDPOINT}/#{activity.id}", headers: auth_headers }
      end

      describe 'mandate activity' do
        let!(:permitted_user) { create(:user) }
        let!(:user_group) do
          create(:user_group, users: [permitted_user], mandate_groups: [mandate_group], roles: [:mandates_read])
        end
        let(:activity) { mandate_activity }

        permit :mandates_read

        describe '(xlsx request)' do
          let!(:user_group) do
            create(:user_group, users: [permitted_user], mandate_groups: [mandate_group], roles: [:mandates_export])
          end
          let(:endpoint) do
            ->(h) { get "#{ACTIVITIES_ENDPOINT}/#{activity.id}", headers: xlsx_headers(h) }
          end

          permit :mandates_export
        end
      end

      describe 'mandate activity without mandate permission' do
        let(:activity) { forbidden_mandate_activity }

        permit # no role permits access to activity with missing mandate permission
      end

      describe 'contact activity' do
        let(:activity) { contact_activity }

        permit :contacts_read

        describe '(xlsx request)' do
          let(:endpoint) do
            ->(h) { get "#{ACTIVITIES_ENDPOINT}/#{activity.id}", headers: xlsx_headers(h) }
          end

          permit :contacts_export
        end
      end
    end

    describe '#create' do
      let!(:permitted_user) { create(:user) }
      let(:endpoint) do
        ->(auth_headers) { post ACTIVITIES_ENDPOINT, params: payload.to_json, headers: auth_headers }
      end
      let(:payload) do
        {
          data: {
            type: 'activities',
            attributes: {
              description: 'Description',
              title: 'Note',
              'activity-type': 'Activity::Note'
            },
            relationships: {
              record_type => {
                data: [
                  { id: record.id, type: record_type }
                ]
              }
            }
          }
        }
      end

      describe 'activity for permitted mandate' do
        let!(:permitted_user) { create(:user) }
        let!(:user_group) do
          create(:user_group, users: [permitted_user], mandate_groups: [mandate_group], roles: [:mandates_write])
        end
        let(:record) { permitted_mandate }
        let(:record_type) { 'mandates' }

        permit :mandates_write
      end

      describe 'activity for mandate without permission' do
        let(:record) { random_mandate }
        let(:record_type) { 'mandates' }

        permit # no role permits creation of activity for mandate without permissions
      end

      describe 'activity for contact' do
        let!(:permitted_user) { create(:user) }
        let!(:user_group) do
          create(:user_group, users: [permitted_user], mandate_groups: [], roles: [:contacts_write])
        end
        let(:record) { contact }
        let(:record_type) { 'contacts' }

        permit :contacts_write
      end

      describe '(xlsx request)' do
        let(:record) { contact }
        let(:record_type) { 'contacts' }
        let(:endpoint) do
          ->(h) { post ACTIVITIES_ENDPOINT, params: payload.to_json, headers: xlsx_headers(h) }
        end

        permit # none
      end
    end

    describe '#update', bullet: false do
      let(:endpoint) do
        lambda do |auth_headers|
          patch "#{ACTIVITIES_ENDPOINT}/#{activity.id}", params: payload.to_json, headers: auth_headers
        end
      end
      let(:payload) do
        {
          data: {
            attributes: {
              description: 'Updated description'
            },
            id: activity.id,
            type: 'activities'
          }
        }
      end

      describe 'mandate activity' do
        describe 'permitted mandate' do
          let!(:permitted_user) { create(:user) }
          let!(:user_group) do
            create(:user_group, users: [permitted_user], mandate_groups: [mandate_group], roles: [:mandates_write])
          end
          let(:activity) { mandate_activity }

          permit :mandates_write

          describe '(xlsx request)' do
            let(:endpoint) do
              lambda do |h|
                patch "#{ACTIVITIES_ENDPOINT}/#{activity.id}", params: payload.to_json, headers: xlsx_headers(h)
              end
            end

            permit # none
          end
        end

        describe 'mandate without permission' do
          let(:activity) { forbidden_mandate_activity }

          permit # no role permits to update an activity of a forbidden mandate
        end
      end

      describe 'contact activity' do
        let(:activity) { contact_activity }

        permit :contacts_write

        describe '(xlsx request)' do
          let(:endpoint) do
            lambda do |h|
              patch "#{ACTIVITIES_ENDPOINT}/#{activity.id}", params: payload.to_json, headers: xlsx_headers(h)
            end
          end

          permit # none
        end
      end
    end

    describe '#destroy' do
      let(:endpoint) { ->(auth_headers) { delete "#{ACTIVITIES_ENDPOINT}/#{activity.id}", headers: auth_headers } }

      describe 'mandate activity' do
        describe 'permitted mandate' do
          let!(:permitted_user) { create(:user) }
          let!(:user_group) do
            create(:user_group, users: [permitted_user], mandate_groups: [mandate_group], roles: [:mandates_destroy])
          end
          let(:activity) { mandate_activity }

          permit :mandates_destroy

          describe '(xlsx request)' do
            let(:endpoint) do
              ->(h) { delete "#{ACTIVITIES_ENDPOINT}/#{activity.id}", headers: xlsx_headers(h) }
            end

            permit # none
          end
        end

        describe 'mandate without permission' do
          let(:activity) { forbidden_mandate_activity }

          permit # no role permits to destroy an activity of a forbidden mandate
        end
      end

      describe 'contact activity' do
        let(:activity) { contact_activity }

        permit :contacts_destroy

        describe '(xlsx request)' do
          let(:endpoint) do
            ->(h) { delete "#{ACTIVITIES_ENDPOINT}/#{activity.id}", headers: xlsx_headers(h) }
          end

          permit # none
        end
      end
    end
  end
end
