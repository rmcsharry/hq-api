# frozen_string_literal: true

# Score activities when they get added
module ScoreableActivity
  extend ActiveSupport::Concern

  included do
    has_and_belongs_to_many :contacts, -> { distinct }
    has_and_belongs_to_many :mandates, -> { distinct }

    before_destroy do
      contacts.each do |contact|
        self.class.update_contact_after_commit(contact: contact)
      end
    end

    after_add_for_contacts << lambda do |_hook, _activity, contact|
      update_contact_after_commit(contact: contact)
    end

    after_remove_for_contacts << lambda do |_hook, _activity, contact|
      update_contact_after_commit(contact: contact)
    end
  end

  class_methods do
    def update_contact_after_commit(contact:)
      contact.update(updated_at: Time.zone.now) # Alternative: contact.update(data_integrity_score: 0)
      contact.execute_after_related_commit do
        contact.reload
        contact.calculate_score
        contact.save!
      end
    end
  end

  private

  def one_activity?(object:)
    object.activities.count == 1
  end
end
