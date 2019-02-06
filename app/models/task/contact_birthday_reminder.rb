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

class Task
  # Defines the model for automatically created contact birthday reminders
  class ContactBirthdayReminder < Task
    def self.policy_class
      TaskPolicy
    end

    validates :subject, presence: true
    validates :linked_object, presence: true

    def subject=(contact)
      apply_defaults!(contact)

      super(contact)
    end

    # Finds contacts whose birthday is due within given time but
    # do not yet have a reminder set
    def self.disregarded_contacts_with_birthday_within(time)
      Contact
        .joins('LEFT OUTER JOIN tasks t ON contacts.id = t.subject_id')
        .where('t.subject_id IS NULL')
        .where(birthday_within_condition(time))
    end

    class << self
      private

      def birthday_within_condition(time)
        start_date = Time.zone.now.strftime('%m%d')
        end_date = (Time.zone.now + time).strftime('%m%d')

        if start_date < end_date
          "to_char(date_of_birth, 'MMDD') BETWEEN '#{start_date}' AND '#{end_date}'"
        else
          <<-SQL.squish
            to_char(date_of_birth, 'MMDD') BETWEEN '0101' AND '#{end_date}' OR
            to_char(date_of_birth, 'MMDD') BETWEEN '#{start_date}' AND '1231'
          SQL
        end
      end
    end

    private

    def apply_defaults!(contact)
      return unless contact.is_a? Contact

      self.assignees = contact.task_assignees
      self.linked_object = contact

      return if contact.date_of_birth.nil?

      decorated_contact = contact.decorate
      self.title = derived_title(decorated_contact)
      self.description = derived_description(decorated_contact)
      self.due_at = decorated_contact.next_birthday
    end

    def derived_title(contact)
      birthday_string = I18n.l(contact.next_birthday)
      "#{contact.name} hat am #{birthday_string} Geburtstag"
    end

    def derived_description(contact)
      birthday = contact.next_birthday
      next_age = birthday.year - contact.date_of_birth.year
      birthday_string = I18n.l(birthday)
      "Der Kontakt #{contact.name} hat am #{birthday_string} Geburtstag und wird #{next_age} Jahre alt."
    end
  end
end
