# frozen_string_literal: true

module Scoreable
  # Score related objects (mandate) when a reltionship role
  # is FIRST ADDED TO or FINALLY REMOVED FROM the related objects
  module ContactRelationship
    extend ActiveSupport::Concern

    included do
      after_commit :rescore_owner
    end

    private

    def rescore_owner
      return unless score_impacted?

      target_contact.calculate_score # NOTE since owner is a mandate, this will trigger calling factor_owners_into_score
      target_contact.save!
    end

    def already_has_role?
      return true if target_contact.passive_contact_relationships.where('role = ?', role).count > 1
    end

    def rule_does_not_apply?
      target_contact.type != 'Contact::Organization'
    end

    def score_impacted?
      return false if rule_does_not_apply? || already_has_role?

      # does the added role match the relationships rule for the contact?
      target_contact.class::SCORE_RULES.select { |r| r[:model_key] == 'passive_contact_relationships' }.each do |rule|
        _, value = rule[:name].split('==')
        return true if role == value
      end
      false
    end
  end
end
