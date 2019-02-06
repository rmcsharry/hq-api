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

RSpec.describe Task::ContactBirthdayReminder, type: :model do
  subject { build(:contact_birthday_reminder) }

  it { is_expected.to validate_presence_of(:subject) }
  it { is_expected.to validate_presence_of(:linked_object) }

  describe 'self.disregarded_contacts_with_birthay_within' do
    let!(:person_1) { create(:contact_person, date_of_birth: Time.zone.local(1990, 1, 10)) }
    let!(:person_2) { create(:contact_person, date_of_birth: Time.zone.local(1990, 12, 31)) }
    let!(:person_with_reminder) { create(:contact_person, date_of_birth: Time.zone.local(1990, 1, 9)) }
    let!(:reminder) { create(:contact_birthday_reminder, subject: person_with_reminder) }

    it 'finds people whose birthday is approaching but are not yet subject of a reminder' do
      Timecop.freeze(Time.zone.local(2019, 1, 1)) do
        people_with_birthday = Task::ContactBirthdayReminder.disregarded_contacts_with_birthday_within 10.days

        expect(people_with_birthday).to include(person_1)
        expect(people_with_birthday).not_to include(person_2)
      end
    end

    it 'does even work if years are about to turn' do
      Timecop.freeze(Time.zone.local(2019, 12, 30)) do
        people_with_birthday = Task::ContactBirthdayReminder.disregarded_contacts_with_birthday_within 14.days

        expect(people_with_birthday).to include(person_1)
        expect(people_with_birthday).to include(person_2)
      end
    end

    it 'does not find people if none are disregarded' do
      people_with_birthday = Task::ContactBirthdayReminder.disregarded_contacts_with_birthday_within 2.days

      expect(people_with_birthday).to be_empty
    end
  end

  describe 'automatic derivation of linked_object', bullet: false do
    let!(:user) { create(:user) }
    let!(:reminder) { build(:contact_birthday_reminder) }
    let!(:person) { create(:contact_person) }

    it 'assigns the person' do
      reminder.subject = person

      expect(reminder.linked_object).to eq(person)
    end
  end

  describe 'automatic derivation of title and description', bullet: false do
    let!(:user) { create(:user) }
    let!(:reminder) { build(:contact_birthday_reminder) }
    let!(:person) { create(:contact_person, date_of_birth: Time.zone.local(1990, 1, 10)).decorate }

    it 'works for straightforward cases' do
      Timecop.freeze(Time.zone.local(2019, 1, 1)) do
        reminder.subject = person

        expect(reminder.title).to eq("#{person.name} hat am 10.01.2019 Geburtstag")
        expect(reminder.description).to include('am 10.01.2019 Geburtstag')
        expect(reminder.description).to include('wird 29 Jahre alt')
      end
    end

    it 'works if year is about to turn' do
      Timecop.freeze(Time.zone.local(2018, 12, 30)) do
        reminder.subject = person

        expect(reminder.title).to eq("#{person.name} hat am 10.01.2019 Geburtstag")
        expect(reminder.description).to include('am 10.01.2019 Geburtstag')
        expect(reminder.description).to include('wird 29 Jahre alt')
      end
    end
  end

  describe 'automatic derivation of assignees', bullet: false do
    let!(:uninvolved_user) { create(:user) }
    let!(:user) { create(:user) }
    let!(:reminder) { build(:contact_birthday_reminder) }

    let!(:hq_contact_person) { create(:contact_person, user: user) }
    let!(:person) { create(:contact_person) }
    let!(:mandate) { create(:mandate) }
    let!(:mandate_member) { create(:mandate_member, contact: person, mandate: mandate, member_type: 'owner') }

    it 'detects mandate primary_consultants' do
      mandate.update primary_consultant: hq_contact_person
      reminder.subject = person

      expect(reminder.assignees).to eq([hq_contact_person.user])
    end

    it 'detects mandate secondary_consultants' do
      mandate.update secondary_consultant: hq_contact_person
      reminder.subject = person

      expect(reminder.assignees).to eq([hq_contact_person.user])
    end

    it 'detects mandate assistants' do
      mandate.update assistant: hq_contact_person
      reminder.subject = person

      expect(reminder.assignees).to eq([hq_contact_person.user])
    end

    it 'does not add bookkeepers' do
      mandate.update bookkeeper: hq_contact_person
      reminder.subject = person

      expect(reminder.assignees).to eq([])
    end

    it 'adds users only once' do
      mandate.update assistant: hq_contact_person
      mandate.update primary_consultant: hq_contact_person
      reminder.subject = person

      expect(reminder.assignees).to eq([hq_contact_person.user])
    end
  end
end
