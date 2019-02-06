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
  # Defines the model for automatically created document expiry reminders
  class DocumentExpiryReminder < Task
    def self.policy_class
      TaskPolicy
    end

    validates :subject, presence: true
    validates :linked_object, presence: true

    def subject=(subject)
      apply_defaults!(subject)

      super(subject)
    end

    # Finds documents that are expiring within given amount of time but
    # do not yet have a reminder set
    def self.disregarded_documents_expiring_within(time)
      Document
        .joins('LEFT OUTER JOIN tasks t ON documents.id = t.subject_id')
        .where('t.subject_id IS NULL AND documents.valid_to <= ?', Time.zone.now + time)
    end

    private

    def apply_defaults!(document)
      return unless document.is_a? Document

      self.assignees = derived_assignees(document)
      self.linked_object = derived_linked_object(document)
      self.title = derived_title(document)

      return if document.valid_to.nil?

      self.description = derived_description(document)
      self.due_at = document.valid_to
    end

    def derived_assignees(subject)
      return [] unless subject.owner.respond_to?(:task_assignees)

      subject.owner.task_assignees
    end

    def derived_linked_object(subject)
      return subject.owner if subject.owner.is_a? Contact

      return subject.owner if subject.owner.is_a? Mandate

      nil
    end

    def derived_title(document)
      "Dokument läuft ab: #{document.name}"
    end

    def derived_description(document)
      valid_to_string = I18n.l(document.valid_to)

      "Das Dokument ist gültig bis zum #{valid_to_string}. Bitte laden Sie eine gültige Version des Dokuments hoch."
    end
  end
end
