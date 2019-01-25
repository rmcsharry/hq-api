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

RSpec.describe Task::DocumentExpiryReminder, type: :model do
  subject { build(:document_expiry_reminder) }

  it { is_expected.to validate_presence_of(:subject) }
  it { is_expected.to validate_presence_of(:linked_object) }

  describe 'self.disregarded_documents_expiring_within' do
    let!(:valid_document) { create(:document, valid_to: 11.days.from_now) }
    let!(:expiring_document) { create(:document, valid_to: 9.days.from_now) }
    let!(:expiring_document_with_reminder) { create(:document, valid_to: 1.day.from_now) }
    let!(:reminder) { create(:document_expiry_reminder, subject: expiring_document_with_reminder) }

    it 'finds documents that are expiring soon but not yet subject of a reminder' do
      expiring_documents = Task::DocumentExpiryReminder.disregarded_documents_expiring_within 10.days

      expect(expiring_documents).to eq([expiring_document])
    end

    it 'does not find documents if none are disregarded' do
      expiring_documents = Task::DocumentExpiryReminder.disregarded_documents_expiring_within 2.days

      expect(expiring_documents).to eq([])
    end
  end

  describe 'automatic derivation of title and description', bullet: false do
    let!(:user) { create(:user) }
    let!(:reminder) { build(:document_expiry_reminder) }
    let!(:hq_contact_person) { create(:contact_person, user: user) }
    let!(:document) { create(:document, name: 'Super Dokument', valid_to: Date.new(2019, 1, 1)) }

    it 'works with given document name and validity date' do
      reminder.subject = document

      expect(reminder.title).to eq('Dokument läuft ab: Super Dokument')
      expect(reminder.description).to include('gültig bis zum 01.01.2019')
    end
  end

  describe 'automatic derivation of linked_object', bullet: false do
    let!(:user) { create(:user) }
    let!(:reminder) { build(:document_expiry_reminder) }
    let!(:hq_contact_person) { create(:contact_person, user: user) }

    context 'when document owner is an activity' do
      let!(:activity) { create(:activity_email, creator: user) }
      let!(:document) { create(:document, owner: activity) }

      it 'assigns nothing' do
        reminder.subject = document

        expect(reminder.linked_object).to be_nil
      end
    end

    context 'when document owner is a contact' do
      let!(:mandate) { create(:mandate) }
      let!(:person) { create(:contact_person) }
      let!(:mandate_member) { create(:mandate_member, contact: person, mandate: mandate, member_type: 'owner') }
      let!(:document) { create(:document, owner: person) }

      it 'assigns contact' do
        reminder.subject = document

        expect(reminder.linked_object).to eq(person)
      end
    end

    context 'when document owner is a mandate' do
      let!(:mandate) { create(:mandate) }
      let!(:mandate_member) { create(:mandate_member, mandate: mandate, member_type: 'owner') }
      let!(:document) { create(:document, owner: mandate) }

      it 'assigns mandate' do
        reminder.subject = document

        expect(reminder.linked_object).to eq(mandate)
      end
    end
  end

  describe 'automatic derivation of assignees', bullet: false do
    let!(:uninvolved_user) { create(:user) }
    let!(:user) { create(:user) }
    let!(:reminder) { build(:document_expiry_reminder) }
    let!(:hq_contact_person) { create(:contact_person, user: user) }

    context 'when document owner is an activity' do
      let!(:activity) { create(:activity_email, creator: user) }
      let!(:document) { create(:document, owner: activity) }

      it 'assigns activity creator' do
        reminder.subject = document

        expect(reminder.assignees).to eq([user])
      end
    end

    context 'when document owner is a contact' do
      let!(:mandate) { create(:mandate) }
      let!(:person) { create(:contact_person) }
      let!(:mandate_member) { create(:mandate_member, contact: person, mandate: mandate, member_type: 'owner') }
      let!(:document) { create(:document, owner: person) }

      it 'assigns mandates primary_consultants' do
        mandate.update primary_consultant: hq_contact_person
        reminder.subject = document

        expect(reminder.assignees).to eq([hq_contact_person.user])
      end

      it 'detects mandate secondary_consultants' do
        mandate.update secondary_consultant: hq_contact_person
        reminder.subject = document

        expect(reminder.assignees).to eq([hq_contact_person.user])
      end

      it 'detects mandate assistants' do
        mandate.update assistant: hq_contact_person
        reminder.subject = document

        expect(reminder.assignees).to eq([hq_contact_person.user])
      end

      it 'does not add bookkeepers' do
        mandate.update bookkeeper: hq_contact_person
        reminder.subject = document

        expect(reminder.assignees).to eq([])
      end

      it 'adds users only once' do
        mandate.update assistant: hq_contact_person
        mandate.update primary_consultant: hq_contact_person
        reminder.subject = document

        expect(reminder.assignees).to eq([hq_contact_person.user])
      end
    end

    context 'when document owner is a mandate' do
      let!(:mandate) { create(:mandate) }
      let!(:mandate_member) { create(:mandate_member, mandate: mandate, member_type: 'owner') }
      let!(:document) { create(:document, owner: mandate) }

      it 'assigns mandates primary_consultants' do
        mandate.update primary_consultant: hq_contact_person
        reminder.subject = document

        expect(reminder.assignees).to eq([hq_contact_person.user])
      end

      it 'detects mandate secondary_consultants' do
        mandate.update secondary_consultant: hq_contact_person
        reminder.subject = document

        expect(reminder.assignees).to eq([hq_contact_person.user])
      end

      it 'detects mandate assistants' do
        mandate.update assistant: hq_contact_person
        reminder.subject = document

        expect(reminder.assignees).to eq([hq_contact_person.user])
      end

      it 'does not add bookkeepers' do
        mandate.update bookkeeper: hq_contact_person
        reminder.subject = document

        expect(reminder.assignees).to eq([])
      end

      it 'adds users only once' do
        mandate.update assistant: hq_contact_person
        mandate.update primary_consultant: hq_contact_person
        reminder.subject = document

        expect(reminder.assignees).to eq([hq_contact_person.user])
      end
    end
  end
end
