# frozen_string_literal: true

module Scoreable
  # Score related objects (mandate) when a relationship role
  # is FIRST ADDED TO or FINALLY REMOVED FROM the related objects
  module ContactRelationship
    extend ActiveSupport::Concern

    included do
      after_commit :rescore_owner
    end

    private

    def rescore_owner
      return unless score_impacted?

      target_contact.rescore # NOTE since owner is a mandate, this will trigger calling factor_owners_into_score
    end

    def score_impacted?
      less_than_two? && rule_applies? && relevant_role?
    end

    def less_than_two?
      target_contact.passive_contact_relationships.where('role = ?', role).count < 2
    end

    def rule_applies?
      target_contact.type == 'Contact::Organization'
    end

    def relevant_role?
      # does the added role match the relationships rule for the contact?
      rules = target_contact.class::SCORE_RULES.select { |r| r[:model_key] == 'passive_contact_relationships' }
      rules.any? { |rule| rule[:name].split('==')[1] == role }
    end
  end
end
