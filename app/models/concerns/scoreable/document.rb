# frozen_string_literal: true

module Scoreable
  # Score related objects (contact/mandate) when a document of a given type
  # is FIRST ADDED TO or FINALLY REMOVED FROM the related objects
  module Document
    extend ActiveSupport::Concern

    included do
      after_commit :rescore
    end

    def rescore
      return unless score_impacted? # no need to recalculate owner score if document does not match the score rule

      owner.class.skip_callback(:save, :before, :calculate_score, raise: false)
      owner.calculate_score
      owner.save!
      owner.class.set_callback(:save, :before, :calculate_score, if: :has_changes_to_save?)
    end

    def score_impacted?
      # did we save changes that relate to the documents rule for the owner?
      rule = owner.class::SCORE_RULES.select { |r| r[:model_key] == 'documents' }[0]
      field, value = rule[:name].split('==')
      changes = saved_changes[field]
      changes&.select { |change| change == value }&.any?
    end
  end
end
