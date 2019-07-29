# frozen_string_literal: true

module Scoreable
  # Score related objects (contact/mandate) when a document of a given type
  # is FIRST ADDED TO or FINALLY REMOVED FROM the related objects
  module Document
    extend ActiveSupport::Concern

    included do
      after_commit :rescore#, if: :saved_change_to_category
    end

    def rescore
      return unless score_impacted?

      owner.class.skip_callback(:save, :before, :calculate_score, raise: false)
      owner.calculate_score
      owner.save!
      owner.class.set_callback(:save, :before, :calculate_score, if: :has_changes_to_save?)
    end

    def score_impacted?
      # did we save changes that relate to the rule for this model?
      rule = owner.class::SCORE_RULES.select { |r| r[:model_key] == 'documents' }[0]
      field, value = rule[:name].split('==')
      changes = saved_changes[field]
      changes.select { |change| change == value }.any? unless changes.nil?
    end
  end
end
