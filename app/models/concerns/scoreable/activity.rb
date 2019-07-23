# frozen_string_literal: true

module Scoreable
  # Score related objects (contct/mandate) when an activity is FIRST ADDED TO or FINALLY REMOVED FROM the related objects
  module Activity
    extend ActiveSupport::Concern

    included do
      has_and_belongs_to_many :contacts, -> { distinct }, after_add: :rescore_contact, before_remove: :rescore_contact
      has_and_belongs_to_many :mandates, -> { distinct }, after_add: :rescore_mandate, before_remove: :rescore_mandate

      before_destroy do
        contacts.each do |contact|
          self.class.store_callback_to_rescore(contact) if contact.one_activity?
        end
        mandates.each do |mandate|
          self.class.store_callback_to_rescore(mandate) if mandate.one_activity?
        end
      end

      def rescore_contact(contact)
        self.class.store_callback_to_rescore(contact) if contact.one_activity?
      end

      def rescore_mandate(mandate)
        self.class.store_callback_to_rescore(mandate) if mandate.one_activity?
      end
    end

    class_methods do
      def store_callback_to_rescore(object)
        object.update(updated_at: Time.zone.now) # Needed only for the execute callbacks on the related object to fire
        object.execute_after_commit do
          object.class.skip_callback(:save, :before, :calculate_score, raise: false)
          object.reload
          object.calculate_score
          object.save!
          object.class.set_callback(:save, :before, :calculate_score, if: :has_changes_to_save?)
        end
      end
    end
  end
end
