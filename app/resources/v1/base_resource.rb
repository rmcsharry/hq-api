# frozen_string_literal: true

module V1
  # Defines the Base resource for the API
  class BaseResource < JSONAPI::Resource
    include JSONAPI::Authorization::PunditScopedResource
    abstract

    def meta(options)
      return super unless options[:serialization_options][:format] == :xlsx
      serialized_related_objects.merge(serialized_enums)
    end

    protected

    def sanitize_params(params, resource)
      params.transform_keys { |key| key.to_s.underscore }.permit(resource._attributes.keys)
    end

    private

    def serialized_related_objects
      self.class._relationships.each_with_object({}) do |(type, relation), hash|
        hash["#{type.to_s.dasherize}-text"] = @model.send(type)&.to_s if relation.class == JSONAPI::Relationship::ToOne
      end
    end

    def serialized_enums
      return {} unless @model.class.respond_to? :enumerized_attributes
      hash = {}
      enumerized_attributes = @model.class.try(:exportable_attributes) || @model.class.enumerized_attributes
      serialize_attributes!(attributes: enumerized_attributes, hash: hash)
      serialize_dependants!(attributes: enumerized_attributes, hash: hash)
      hash
    end

    def serialize_attributes!(attributes:, hash:)
      attributes.each do |attribute|
        attribute_getter = "#{attribute.name}_text".to_sym
        hash[attribute_getter.to_s.dasherize] = @model.try(attribute_getter)
      end
    end

    def serialize_dependants!(attributes:, hash:)
      attributes.instance_variable_get(:@dependants).each do |dependant|
        serialize_attributes!(attributes: dependant, hash: hash)
        serialize_dependants!(attributes: dependant, hash: hash)
      end
    end
  end
end
