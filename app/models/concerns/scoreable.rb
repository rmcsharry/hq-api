# frozen_string_literal: true

# Concern to calculate data integrity scores for an entity (eg. person, organisation, mandate)
# including building up the list of attributes that are missing (and thus do not add to the score)
module Scoreable
  extend ActiveSupport::Concern

  class_methods do
    def relative_weights_total
      # memoized at class level since WEIGHT_RULES can only change via code deployment
      @relative_weights_total ||= self::WEIGHT_RULES.sum { |rule| rule[:relative_weight] }.to_f
    end

    def get_rule(key, name = '')
      self::WEIGHT_RULES.find(key == :model_key && name == :name).first
    end

    def process_rule(instance:, rule:, direction:)
      processor = RuleProcessor.new(object: instance)
      new_score = instance.data_integrity_score + (processor.score(rule: rule) * direction)
      # instance.updatx_column(:data_integrity_score, new_score)
      instance.data_integrity_score = new_score
      instance.save!
    end
  end

  included do
    # before_save :calculate_score, if: :has_changes_to_save?
  end

  # called by an object, for which we will calculate the total score by applying all WEIGHT_RULES defined for its class
  def calculate_score
    processor = WeightRulesProcessor.new(object: self)
    @score = 0
    @score = self.class::WEIGHT_RULES.sum do |rule|
      processor.score(rule: rule)
    end
    self.data_integrity_missing_fields = processor.missing_fields
    assign_score
  end

  private

  def assign_score
    self.data_integrity_score = @score
  end
end
