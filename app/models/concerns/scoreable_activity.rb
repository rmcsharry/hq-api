# frozen_string_literal: true

# Score activities when they get added
module ScoreableActivity
  extend ActiveSupport::Concern

  included do
    has_and_belongs_to_many :contacts, -> { distinct }
    has_and_belongs_to_many :mandates, -> { distinct }

    before_destroy do
      contacts.each do |contact|
        self.class.update_contact_after_commit(contact: contact) if contact.one_activity?
      end
    end

    after_add_for_contacts << lambda do |_hook, _activity, contact|
      update_contact_after_commit(contact: contact) if contact.one_activity?
    end

    before_remove_for_contacts << lambda do |_hook, _activity, contact|
      update_contact_after_commit(contact: contact) if contact.one_activity?
    end
  end

  class_methods do
    def update_contact_after_commit(contact:)
      contact.update(updated_at: Time.zone.now) # Alternative: contact.update(data_integrity_score: 0)
      contact.execute_after_related_commit do
        Contact.skip_callback(:save, :before, :calculate_score, raise: false)
        contact.reload
        contact.calculate_score
        contact.save!
        Contact.set_callback(:save, :before, :calculate_score, if: :has_changes_to_save?)
      end
    end
  end
end
