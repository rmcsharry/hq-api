# frozen_string_literal: true

# == Schema Information
#
# Table name: tasks
#
#  id                 :uuid             not null, primary key
#  creator_id         :uuid
#  finisher_id        :uuid
#  subject_type       :string
#  subject_id         :uuid
#  linked_object_type :string
#  linked_object_id   :uuid
#  aasm_state         :string           not null
#  description        :string
#  title              :string           not null
#  type               :string           not null
#  finished_at        :datetime
#  due_at             :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_tasks_on_creator_id                               (creator_id)
#  index_tasks_on_finisher_id                              (finisher_id)
#  index_tasks_on_linked_object_type_and_linked_object_id  (linked_object_type,linked_object_id)
#  index_tasks_on_subject_type_and_subject_id              (subject_type,subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (creator_id => users.id)
#  fk_rails_...  (finisher_id => users.id)
#

require 'rails_helper'

RSpec.describe Task, type: :model do
  it { is_expected.to validate_presence_of(:title) }

  it { is_expected.to belong_to(:creator).optional.inverse_of(:created_tasks).class_name('User') }
  it { is_expected.to belong_to(:finisher).optional.inverse_of(:finished_by_user_tasks).class_name('User') }
  it { is_expected.to belong_to(:linked_object).optional.inverse_of(:task_links) }
  it { is_expected.to belong_to(:subject).optional.inverse_of(:reminders) }
  it { is_expected.to have_and_belong_to_many(:assignees).class_name('User') }
  it { is_expected.to have_many(:task_comments) }

  describe '.associated_to_user_with_id' do
    let(:user) { create(:user) }
    let!(:task) { create(:task_simple, assignees: [user, user.clone]) }

    subject { Task.associated_to_user_with_id(user.id) }

    it 'returns all associated tasks' do
      expect(subject.distinct(false)).to eq([task, task])
    end

    it 'returns distinct associated tasks' do
      expect(subject).to eq([task])
    end
  end

  describe '#finish' do
    let(:task) { create :task }
    let(:finisher) { create :user }

    it 'transitions state from :created to :finished' do
      task.state = 'created'
      task.finish(finisher)
      expect(task.state).to eq('finished')
      expect(task.finisher).to eq(finisher)
    end
  end

  describe '#finisher and #finished_at' do
    let(:task) { create :task, state: :created }
    let(:finisher) { create :user }

    it 'are not validated for presence when state is :created' do
      task.finisher = nil
      task.finished_at = nil
      expect(task.valid?).to eq(true)
    end

    it 'are validated for presence when state is :finished' do
      task.finish(finisher)

      task.finisher = nil
      task.finished_at = Time.zone.now
      expect(task.valid?).to eq(false)

      task.finisher = finisher
      task.finished_at = nil
      expect(task.valid?).to eq(false)
    end
  end

  describe '#aasm_state' do
    it { is_expected.to respond_to(:aasm_state) }
    it { is_expected.to respond_to(:state) }
  end

  describe '#description' do
    it { is_expected.to respond_to(:description) }
    it { is_expected.not_to validate_presence_of(:description) }
  end

  describe '#due_at' do
    it { is_expected.to respond_to(:due_at) }
    it { is_expected.not_to validate_presence_of(:due_at) }
  end
end
