# frozen_string_literal: true

module Scoreable
  # Score related objects (contact/mandate) when an activity
  # is FIRST ADDED TO or FINALLY REMOVED FROM the related objects
  module Activity
    extend ActiveSupport::Concern

    included do
      has_and_belongs_to_many :contacts, -> { distinct }, before_add: :rescore_contact, after_remove: :rescore_contact
      has_and_belongs_to_many :mandates, -> { distinct }, before_add: :rescore_mandate, after_remove: :rescore_mandate

      before_destroy do
        contacts.each do |contact|
          self.class.store_callback_to_rescore(contact) if contact.one_activity?
        end
        mandates.each do |mandate|
          self.class.store_callback_to_rescore(mandate) if mandate.one_activity?
        end
      end

      def rescore_contact(contact)
        self.class.store_callback_to_rescore(contact) if contact.no_activities?
      end

      def rescore_mandate(mandate)
        self.class.store_callback_to_rescore(mandate) if mandate.no_activities?
      end
    end

    class_methods do
      def store_callback_to_rescore(object)
        object.update(updated_at: Time.zone.now) # Needed only so that the execute callbacks on the related object fire
        object.execute_after_commit do
          object.reload # without this calculate_score will not see the activity changes
          object.rescore
        end
      end
    end
  end
end
