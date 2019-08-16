# frozen_string_literal: true

module Scoreable
  # Score related objects (contact/mandate) when a document of a given type
  # is FIRST ADDED TO or FINALLY REMOVED FROM the related objects
  module Document
    extend ActiveSupport::Concern

    included do
      after_commit :rescore_owner
    end

    def rescore_owner
      return unless score_impacted? # no need to recalculate owner score if document does not match the score rule

      owner.rescore # NOTE if owner is a mandate, this will trigger calling factor_owners_into_score
    end

    private

    def score_impacted?
      less_than_two? && rule_applies? && relevant_role?
    end

    def less_than_two?
      owner.documents.where('category = ?', category).count < 2
    end

    def rule_applies?
      owner_type == 'Contact' || owner_type == 'Mandate'
    end

    def relevant_role?
      # does the added role match the relationships rule for the contact?
      rules = owner.class::SCORE_RULES.select { |r| r[:model_key] == 'documents' }
      rules.any? { |rule| rule[:name].split('==')[1] == category }
    end
  end
end
