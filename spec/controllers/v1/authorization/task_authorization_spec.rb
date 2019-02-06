# frozen_string_literal: true

require 'rails_helper'
require 'devise/jwt/test_helpers'

RSpec.describe 'authorization for', type: :request do
  context 'tasks through ews' do
    let!(:record) { create(:task) }
    include_examples 'forbid access for ews authenticated users',
                     TASKS_ENDPOINT,
                     resource: 'tasks',
                     except: []
  end

  context 'tasks' do
    let!(:current_user) { create(:user, roles: %i[tasks]) }
    let!(:foreign_user) { create(:user, roles: %i[tasks]) }
    let!(:own_task) { create(:task, creator: current_user) }
    let!(:foreign_task) { create(:task, creator: foreign_user) }
    let!(:assigned_task) { create(:task, creator: foreign_user, assignees: [current_user]) }

    let(:headers) { { 'Content-Type' => 'application/vnd.api+json' } }
    let(:auth_headers) { Devise::JWT::TestHelpers.auth_headers(headers, current_user) }

    describe '#index' do
      let(:endpoint) do
        ->(auth_headers) { get "#{TASKS_ENDPOINT}/#{task.id}", headers: auth_headers }
      end

      context 'of own task' do
        let(:task) { own_task }

        permit :tasks
      end

      context 'of assigned task' do
        let(:task) { assigned_task }

        permit :tasks
      end

      context 'of foreign task' do
        let(:task) { foreign_task }

        permit # none
      end
    end

    describe '#index' do
      let(:endpoint) { ->(auth_headers) { get TASKS_ENDPOINT, headers: auth_headers } }

      permit :tasks

      describe 'filters tasks per user' do
        def response_data
          JSON.parse(response.body)['data']
        end

        it 'does not contain tasks of other users' do
          endpoint.call(auth_headers)

          ids = response_data.map { |task| task['id'] }

          expect(ids).to include(own_task.id)
          expect(ids).to include(assigned_task.id)
          expect(ids).not_to include(foreign_task.id)
        end
      end
    end

    describe '#show' do
      let(:endpoint) do
        ->(auth_headers) { get "#{TASKS_ENDPOINT}/#{task.id}", headers: auth_headers }
      end

      context 'own task' do
        let(:task) { own_task }

        permit :tasks
      end

      context 'assigned task' do
        let(:task) { assigned_task }

        permit :tasks
      end

      context 'foreign task' do
        let(:task) { foreign_task }

        permit # none
      end
    end

    describe '#create' do
      let(:endpoint) do
        lambda do |auth_headers|
          post TASKS_ENDPOINT, params: payload.to_json, headers: auth_headers
        end
      end

      let(:payload) do
        {
          data: {
            attributes: {
              title: 'title',
              'task-type': 'Task::Simple'
            },
            relationships: {
              creator: { data: { type: 'users', id: current_user.id } }
            },
            type: 'tasks'
          }
        }
      end

      permit :tasks
    end

    describe '#update', bullet: false do
      let(:endpoint) do
        lambda do |auth_headers|
          patch "#{TASKS_ENDPOINT}/#{task.id}", params: payload.to_json, headers: auth_headers
        end
      end

      let(:payload) do
        {
          data: {
            attributes: {
              title: 'new title'
            },
            id: task.id,
            type: 'tasks'
          }
        }
      end

      context 'own task' do
        let(:task) { own_task }

        permit :tasks
      end

      context 'assigned task' do
        let(:task) { assigned_task }

        permit :tasks
      end

      context 'foreign task' do
        let(:task) { foreign_task }

        permit # none
      end
    end

    describe '#destroy', bullet: false do
      let(:endpoint) do
        ->(auth_headers) { delete "#{TASKS_ENDPOINT}/#{task.id}", headers: auth_headers }
      end

      context 'own task' do
        let(:task) { own_task }

        permit :tasks
      end

      context 'assigned task' do
        let(:task) { assigned_task }

        permit # none
      end

      context 'foreign task' do
        let(:task) { foreign_task }

        permit # none
      end
    end
  end
end
