# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'authorization for', type: :request do
  context 'task comments through ews' do
    let!(:record) { create(:task) }
    include_examples 'forbid access for ews authenticated users',
                     TASK_COMMENTS_ENDPOINT,
                     resource: 'task-comments',
                     except: []
  end

  context 'task comments' do
    let!(:current_user) { create(:user, roles: %i[tasks]) }
    let!(:foreign_user) { create(:user, roles: %i[tasks]) }
    let!(:own_task) { create(:task, creator: current_user) }
    let!(:own_task_comment) { create(:task_comment, task: own_task, user: current_user) }
    let!(:own_task_foreign_comment) { create(:task_comment, task: own_task, user: foreign_user) }
    let!(:foreign_task) { create(:task, creator: foreign_user) }
    let!(:foreign_task_comment) { create(:task_comment, task: foreign_task, user: current_user) }
    let!(:assigned_task) { create(:task, creator: foreign_user, assignees: [current_user]) }
    let!(:assigned_task_comment) { create(:task_comment, task: assigned_task, user: current_user) }

    let(:headers) { { 'Content-Type' => 'application/vnd.api+json', 'Accept' => 'application/vnd.api+json' } }
    let(:auth_headers) { Devise::JWT::TestHelpers.auth_headers(headers, current_user) }

    describe '#index' do
      let(:endpoint) { ->(auth_headers) { get TASK_COMMENTS_ENDPOINT, headers: auth_headers } }

      permit :tasks

      describe 'filters task comments per user' do
        def response_data
          JSON.parse(response.body)['data']
        end

        it 'does not contain task comments of other users' do
          endpoint.call(auth_headers)

          ids = response_data.map { |task_comment| task_comment['id'] }

          expect(ids).to include(own_task_comment.id)
          expect(ids).to include(own_task_foreign_comment.id)
          expect(ids).to include(assigned_task_comment.id)
          expect(ids).not_to include(foreign_task_comment.id)
        end
      end
    end

    describe '#show' do
      let(:endpoint) do
        ->(auth_headers) { get "#{TASK_COMMENTS_ENDPOINT}/#{task_comment.id}", headers: auth_headers }
      end

      context 'of own task comment' do
        let(:task_comment) { own_task_comment }

        permit :tasks
      end

      context 'of own task foreign comment' do
        let(:task_comment) { own_task_foreign_comment }

        permit :tasks
      end

      context 'of assigned task comment' do
        let(:task_comment) { assigned_task_comment }

        permit :tasks
      end

      context 'of foreign task comment' do
        let(:task_comment) { foreign_task_comment }

        # This is an edge case scenario: User A was once an assignee on Task 1 and created a comment on Task 1.
        # User A then got removed from the assignees. Now, User A cannot see their comment anymore.
        # User A can still update and delete their comment though. It was decided that this is currently fine but
        # the requirement might change in the future.
        permit # none
      end
    end

    describe '#create' do
      let(:endpoint) do
        lambda do |auth_headers|
          post TASK_COMMENTS_ENDPOINT, params: payload.to_json, headers: auth_headers
        end
      end

      let(:payload) do
        {
          data: {
            attributes: {
              comment: 'Lorem ipsum'
            },
            relationships: {
              user: { data: { type: 'users', id: current_user.id } },
              task: { data: { type: 'tasks', id: own_task.id } }
            },
            type: 'task-comments'
          }
        }
      end

      permit :tasks
    end

    describe '#update', bullet: false do
      let(:endpoint) do
        lambda do |auth_headers|
          patch "#{TASK_COMMENTS_ENDPOINT}/#{task_comment.id}", params: payload.to_json, headers: auth_headers
        end
      end

      let(:payload) do
        {
          data: {
            attributes: {
              comment: 'dolor sit amet'
            },
            id: task_comment.id,
            type: 'task-comments'
          }
        }
      end

      context 'own task comment' do
        let(:task_comment) { own_task_comment }

        permit :tasks
      end

      context 'own task foreign comment' do
        let(:task_comment) { own_task_foreign_comment }

        permit # none
      end

      context 'assigned task comment' do
        let(:task_comment) { assigned_task_comment }

        permit :tasks
      end

      context 'foreign task comment' do
        let(:task_comment) { foreign_task_comment }

        permit :tasks
      end
    end

    describe '#destroy', bullet: false do
      let(:endpoint) do
        ->(auth_headers) { delete "#{TASK_COMMENTS_ENDPOINT}/#{task_comment.id}", headers: auth_headers }
      end

      context 'own task comment' do
        let(:task_comment) { own_task_comment }

        permit :tasks
      end

      context 'own task foreign comment' do
        let(:task_comment) { own_task_foreign_comment }

        permit # none
      end

      context 'assigned task comment' do
        let(:task_comment) { assigned_task_comment }

        permit :tasks
      end

      context 'foreign task comment' do
        let(:task_comment) { foreign_task_comment }

        permit :tasks
      end
    end
  end
end
