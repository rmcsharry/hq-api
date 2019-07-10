# frozen_string_literal: true

# Simple processor for a rule
class RuleProcessor
  attr_reader :missing_fields

  def initialize(object:)
    @object = object
    @missing_fields = []
  end

  def score(rule:)
    rule[:relative_weight] / @object.class.relative_weights_total.to_f
  end
end
