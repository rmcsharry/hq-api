# frozen_string_literal: true

module Scoreable
  # Score related objects (contact/mandate) when an activity
  # is FIRST ADDED TO or FINALLY REMOVED FROM the related objects
  module Activity
    extend ActiveSupport::Concern

    included do
      before_destroy do
        contacts.each do |contact|
          self.class.store_callback_to_rescore(contact) if one_activity?(object: contact)
        end
        mandates.each do |mandate|
          self.class.store_callback_to_rescore(mandate) if one_activity?(object: mandate)
        end
      end

      def rescore_contact(contact)
        self.class.store_callback_to_rescore(contact) if no_activities?(object: contact)
      end

      def rescore_mandate(mandate)
        self.class.store_callback_to_rescore(mandate) if no_activities?(object: mandate)
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

    def one_activity?(object:)
      object.activities.count == 1
    end

    def no_activities?(object:)
      object.activities.count.zero?
    end
  end
end
