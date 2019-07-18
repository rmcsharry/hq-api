# frozen_string_literal: true

# A factory class (not meant to be instantiated directly) for processing rules on objects
# Call result with an object and a single rule
# Returns a hash: {score: x, field: name} which is the result of applying the rule on the object
# If the rule does not apply, returns {score: 0.0, field: name}
class RuleFactory
  def initialize(object:, rule:)
    @object = object
    @model = rule[:model_key]
    @property = rule[:name]
    @relative_weight = rule[:relative_weight]
  end

  def self.result(object:, rule:)
    self.for(object: object, rule: rule)
  end

  def self.for(object:, rule:)
    if rule[:model_key] == object.model_name.param_key
      RuleFactory::FromMainModel
    elsif rule[:name].include?('==')
      RuleFactory::FromRelativeFieldValue
    elsif rule[:name].blank?
      RuleFactory::FromRelativeAtLeastOne
    else
      RuleFactory::FromRelativeSpecificProperty
    end.new(object: object, rule: rule).result
  end

  def absolute_weight(field_name, presence_checker)
    if send(presence_checker)
      { score: (@relative_weight / @object.class.relative_weights_total), name: field_name }
    else
      { score: 0.0, name: field_name }
    end
  end

  # rubocop:disable Style/Documentation
  # class Score
  #   def self.result(field_name, presence_checker)
  #     { score: (@relative_weight / @object.class.relative_weights_total), name: field_name }
  #   end
  # end

  # class NoScore
  #   def absolute_weight
  #     { score: 0.0, name: field_name }
  #   end
  # end

  class FromMainModel < RuleFactory
    def result
      absolute_weight(@property.camelize(:lower), :main_property_present?)
    end

    def main_property_present?
      @object.public_send(@property).present?
    end
  end

  class FromRelativeFieldValue < RuleFactory
    def result
      absolute_weight(@property.split('==')[1], :field_value_present?)
    end

    def field_value_present?
      return false if @object.public_send(@model).nil?

      field, value = @property.split('==')
      @object.public_send(@model).where("#{field}": value).present?
    end
  end

  class FromRelativeAtLeastOne < RuleFactory
    def result
      absolute_weight(@model, :at_least_one_present?)
    end

    def at_least_one_present?
      return false if @object.public_send(@model).nil?

      @object.public_send(@model).present?
    end
  end

  class FromRelativeSpecificProperty < RuleFactory
    def result
      absolute_weight(@property.camelize(:lower), :specific_property_present?)
    end

    def specific_property_present?
      return false if @object.public_send(@model).nil?

      @object.public_send(@model)[@property].present?
    end
  end
  # rubocop:enable Style/Documentation
end
