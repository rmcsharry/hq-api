# frozen_string_literal: true

module Scoreable
  # Score related objects (mandate) when a bank account
  # is FIRST ADDED TO or FINALLY REMOVED FROM the related objects
  module ContactRelationship
    extend ActiveSupport::Concern

    included do
      after_create :rescore_owner, if: -> { only_one_relationship_for_role? }
      after_destroy :rescore_owner, if: -> { no_relationships_for_role? }
    end

    def rescore_owner
      return unless score_impacted?

      target_contact.calculate_score # NOTE since owner is a mandate, this will trigger calling factor_owners_into_score
      target_contact.save!
    end

    private

    def only_one_relationship_for_role?
      target_contact.passive_contact_relationships.where('role = ?', role).count == 1
    end

    def no_relationships_for_role?
      target_contact.passive_contact_relationships.where('role = ?', role).count.zero?
    end

    def score_impacted?
      return false unless target_contact.type == 'Contact::Organization'

      # does the relationship match the relationships rule for the contact?
      target_contact.class::SCORE_RULES.select { |r| r[:model_key] == 'passive_contact_relationships' }.each do |rule|
        _, value = rule[:name].split('==')
        return true if role == value
      end
      false
    end
  end
end
