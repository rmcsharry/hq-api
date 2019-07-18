# frozen_string_literal: true

# Rule is an abstract factory class (not meant to be instantiated directly)
# Used to build rules based on its descendant classes and apply those rules to objects (contacts, mandates etc)
#
# HOW TO USE
# Call Rule.build and provide:
#  1 an object
#  2 a single rule
#
# RETURNS
#  an instance of a descendant class matching the given rule type
#
# Calling 'result' on that instance returns a hash:
# {score: x, name: field to show to user}
# If the rule does not apply, the result will be {score: 0.0, name: field to show to user}
class Rule
  def initialize(object:, rule:)
    @object = object
    @model = rule[:model_key]
    @property = rule[:name]
    @relative_weight = rule[:relative_weight]
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

  private

  def absolute_weight(field_name, presence_checker)
    if send(presence_checker)
      { score: (@relative_weight / @object.class.relative_weights_total), name: field_name }
    else
      { score: 0.0, name: field_name }
    end
  end

  # rubocop:disable Style/Documentation
  class MainProperty < Rule
    def result
      absolute_weight(@property.camelize(:lower), :main_property_present?)
    end

    def main_property_present?
      @object.public_send(@property).present?
    end
  end

  class RelativeProperty < Rule
    def result
      absolute_weight(@property.camelize(:lower), :specific_property_present?)
    end

    def specific_property_present?
      return false if @object.public_send(@model).nil?

      @object.public_send(@model)[@property].present?
    end
  end

  class RelativeFieldValue < Rule
    def result
      absolute_weight(@property.split('==')[1], :field_value_present?)
    end

    def field_value_present?
      return false if @object.public_send(@model).nil?

      field, value = @property.split('==')
      @object.public_send(@model).where("#{field}": value).present?
    end
  end

  class RelativeAtLeastOne < Rule
    def result
      absolute_weight(@model, :at_least_one_present?)
    end

    def at_least_one_present?
      return false if @object.public_send(@model).nil?

      @object.public_send(@model).present?
    end
  end
  # rubocop:enable Style/Documentation
end
