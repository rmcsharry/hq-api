# frozen_string_literal: true

module Scoreable
  # Factory to return a score result for a given rule
  # Designed so that rules send themselves to be scored
  #
  # INPUT
  # Call Score.build and provide:
  #  a single rule
  #
  # OUTPUT
  #  {name: <attribute scored>, score: <x>}
  #  {name: <attribute scored>, score: <0.0>} -> if the rule is invalid or does not pass
  class Score
    def initialize(rule)
      @rule = rule
    end

    def self.build(rule)
      descendants.detect { |klass| klass.match? rule }.new(rule).result
    end

    def self.inherited(klass)
      descendants.push klass
    end

    def self.descendants
      @descendants ||= []
    end

    def result
      { name: @rule.field_name, score: 0.0 }
    end

    # rubocop:disable Style/Documentation
    class InvalidZero < Score
      def self.match?(rule)
        !rule.valid?
      end
    end

    class ValidZero < Score
      def self.match?(rule)
        rule.valid? && !rule.passed?
      end
    end

    class NotZero < Score
      def self.match?(rule)
        rule.valid? && rule.passed?
      end

      def result
        { name: @rule.field_name, score: (@rule.relative_weight / @rule.weights_total) }
      end
    end
  end
  # rubocop:enable Style/Documentation
end
