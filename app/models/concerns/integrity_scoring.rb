# frozen_string_literal: true

# Concern to calculate data integrity scores for an entity (eg. person, organisation, mandate)
# including building up the list of attributes that are missing (and thus do not add to the score)
module IntegrityScoring
  extend ActiveSupport::Concern

  class_methods do
    def relative_weights_total
      # memoized at class level since WEIGHTS can only change via code deployment
      @relative_weights_total ||= self::WEIGHT_RULES.sum { |rule| rule[:relative_weight] }
    end
  end

  included do
    before_save :calculate_score, if: :has_changes_to_save? # NOTE: this callback is disabled in tests
  end

  # called by a model instance, which is the object we will calculate the total score for by applying all rules
  def calculate_score
    @integrity_score = 0
    @integrity_score = self.class::WEIGHT_RULES.sum do |rule|
      weight = IntegrityWeight.new(object: self, rule: rule)
      weight.score
    end
    assign_score
  end

  private

  def assign_score
    self.data_integrity_score = @integrity_score
  end
end
