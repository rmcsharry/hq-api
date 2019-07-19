# frozen_string_literal: true

# Rule is an abstract factory class (not meant to be instantiated directly)
# Used to build rules based on its descendant classes and apply those rules to objects (contacts, mandates etc)
#
# INPUT
# Call Rule.build and provide:
#  1 an object
#  2 a single rule
#
# OUTPUT
#  an instance of the descendant class that matches the given rule type
#  call result on the instance -> returns hash: {score: x, name: field scored}
#
# If the rule does not apply, the result will be {score: 0.0, name: field scored}
class Rule
  attr_accessor :field_name, :relative_weight, :weights_total

  def initialize(object:, rule:)
    @object = object
    @model, @property, @relative_weight = rule[:model_key], rule[:name], rule[:relative_weight]
    @weights_total = object.class.relative_weights_total
  end

  def self.build(object:, rule:)
    descendants.detect { |klass| klass.name.demodulize == rule[:type] }.new(object: object, rule: rule)
  end

  def self.inherited(klass)
    descendants.push klass
  end

  def self.descendants
    @descendants ||= []
  end

  def valid?
    !@object.public_send(@model).nil?
  end

  # rubocop:disable Style/Documentation
  class MainProperty < Rule
    def result
      @field_name = @property.camelize(:lower)
      Score.build(self).result
    end

    def passed?
      @object.public_send(@property).present?
    end

    def valid?
      true # rules on main are always valid (else dev error)
    end
  end

  class RelativeProperty < Rule
    def result
      @field_name = @property.camelize(:lower)
      Score.build(self).result
    end

    def passed?
      @object.public_send(@model)[@property].present?
    end
  end

  class RelativeFieldValue < Rule
    def result
      _, @field_name = @property.split('==')
      Score.build(self).result
    end

    def passed?
      field, value = @property.split('==')
      @object.public_send(@model).where("#{field}": value).present?
    end
  end

  class RelativeAtLeastOne < Rule
    def result
      @field_name = @model
      Score.build(self).result
    end

    def passed?
      @object.public_send(@model).present?
    end
  end

  class Score
    def initialize(rule)
      @rule = rule
    end

    def self.build(rule)
      descendants.detect { |klass| klass.match? rule }.new(rule)
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
