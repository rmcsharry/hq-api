# frozen_string_literal: true

module Scoreable
  # Rule is an abstract factory class (not meant to be instantiated directly)
  # Used to build rules based on its descendant classes and apply those rules to objects (contacts, mandates etc)
  #
  # INPUT
  # Call Rule.build and provide:
  #  1 an object
  #  2 a single rule
  #
  # OUTPUT (the result of Score class)
  #  {score: <x>, name: <field scored>}
  #  {score: 0.0, name: <field scored>} -> if the rule is invalid or does not pass
  class Rule
    attr_accessor :field_name, :relative_weight, :weights_total

    def initialize(object:, rule:)
      @object = object
      @model = rule[:model_key]
      @property = rule[:name]
      @relative_weight = rule[:relative_weight]
      @weights_total = object.class.relative_weights_total
    end

    def self.build(object:, rule:)
      descendants.detect { |klass| klass.name.demodulize == rule[:type] }.new(object: object, rule: rule).result
    end

    def self.inherited(klass)
      descendants.push klass
    end

    def self.descendants
      @descendants ||= []
    end

    def result
      @field_name = @property.camelize(:lower)
      Score.build(self)
    end

    def valid?
      !@object.public_send(@model).nil?
    end

    # rubocop:disable Style/Documentation
    class MainProperty < Rule
      def passed?
        @object.public_send(@property).present?
      end

      def valid?
        true # rules on main are always valid (else dev error)
      end
    end

    class RelativeProperty < Rule
      def passed?
        @object.public_send(@model)[@property].present?
      end
    end

    class RelativeFieldValue < Rule
      def passed?
        field, value = @property.split('==')
        @object.public_send(@model).where("#{field}": value).present?
      end

      def result
        _, @field_name = @property.split('==')
        Score.build(self)
      end
    end

    class RelativeAtLeastOne < Rule
      def passed?
        @object.public_send(@model).present?
      end

      def result
        @field_name = @model
        Score.build(self)
      end
    end
  end
  # rubocop:enable Style/Documentation
end
