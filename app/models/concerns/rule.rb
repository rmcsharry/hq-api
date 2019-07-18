class Rule
  def initialize(object:, rule:)
    @object = object
    @model = rule[:model_key]
    @property = rule[:name]
    @relative_weight = rule[:relative_weight]
  end

  def self.build(object:, rule:)
    descendants.detect { |klass| klass.match?(rule) }.new(object: object, rule: rule)
  end

  def self.inherited(klass)
    descendants.push klass
  end

  def self.descendants
    @descendants ||= []
  end

  def absolute_weight(field_name, presence_checker)
    if send(presence_checker)
      { score: (@relative_weight / @object.class.relative_weights_total), name: field_name }
    else
      { score: 0.0, name: field_name }
    end
  end

  # rubocop:disable Style/Documentation
  class FromMainModel < Rule
    def self.match?(rule)
      rule[:type] == 'A'
    end

    def result
      absolute_weight(@property.camelize(:lower), :main_property_present?)
    end

    def main_property_present?
      @object.public_send(@property).present?
    end
  end

  class FromRelativeSpecificProperty < Rule
    def self.match?(rule)
      rule[:type] == 'B'
    end

    def result
      absolute_weight(@property.camelize(:lower), :specific_property_present?)
    end

    def specific_property_present?
      return false if @object.public_send(@model).nil?

      @object.public_send(@model)[@property].present?
    end
  end

  class FromRelativeFieldValue < Rule
    def self.match?(rule)
      rule[:type] == 'C'
    end

    def result
      absolute_weight(@property.split('==')[1], :field_value_present?)
    end

    def field_value_present?
      return false if @object.public_send(@model).nil?

      field, value = @property.split('==')
      @object.public_send(@model).where("#{field}": value).present?
    end
  end

  class FromRelativeAtLeastOne < Rule
    def self.match?(rule)
      rule[:type] == 'D'
    end

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
