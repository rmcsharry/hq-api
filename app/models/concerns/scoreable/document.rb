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

      owner.calculate_score # NOTE if owner is a mandate, this will trigger calling factor_owners_into_score
      owner.save!
    end

    def score_impacted?
      return false unless owner_type == 'Contact' || owner_type == 'Mandate'

      # does the document match the documents rule for the owner?
      rule = owner.class::SCORE_RULES.select { |r| r[:model_key] == 'documents' }[0]
      _, value = rule[:name].split('==')
      category == value
    end
  end
end