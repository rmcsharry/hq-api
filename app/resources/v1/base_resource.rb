# frozen_string_literal: true

module V1
  # Defines the Base resource for the API
  class BaseResource < JSONAPI::Resource
    include JSONAPI::Authorization::PunditScopedResource
    abstract

    model_hint model: Activity::Call, resource: :activity
    model_hint model: Activity::Email, resource: :activity
    model_hint model: Activity::Meeting, resource: :activity
    model_hint model: Activity::Note, resource: :activity
    model_hint model: Contact::Organization, resource: :contact
    model_hint model: Contact::Person, resource: :contact
    model_hint model: ContactDetail::Email, resource: :contact_detail
    model_hint model: ContactDetail::Fax, resource: :contact_detail
    model_hint model: ContactDetail::Phone, resource: :contact_detail
    model_hint model: ContactDetail::Website, resource: :contact_detail
    model_hint model: Document::FundSubscriptionAgreement, resource: :document
    model_hint model: Document::FundTemplate, resource: :document
    model_hint model: Document::GeneratedDocument, resource: :document
    model_hint model: Fund::PrivateDebt, resource: :fund
    model_hint model: Fund::PrivateEquity, resource: :fund
    model_hint model: Fund::RealEstate, resource: :fund
    model_hint model: Task::ContactBirthdayReminder, resource: :task
    model_hint model: Task::DocumentExpiryReminder, resource: :task
    model_hint model: Task::Simple, resource: :task

    def meta(options)
      return super unless options[:serialization_options][:format] == :xlsx

      serialized_related_objects.merge(serialized_enums)
    end

    protected

    def sanitize_params(params, resource)
      params.transform_keys { |key| key.to_s.underscore }.permit(resource._attributes.keys)
    end

    # TODO: Can be removed when this issue is solved: https://github.com/cerebris/jsonapi-resources/issues/1160
    def _replace_polymorphic_to_one_link(relationship_type, key_value, key_type, _options)
      relationship = self.class._relationships[relationship_type.to_sym]

      send("#{relationship.foreign_key}=", type: self.class.model_name_for_type(key_type), id: key_value)
      @save_needed = true

      :completed
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

    class << self
      def construct_order_options(sort_params, table_alias = nil)
        field = [table_alias, 'id'].compact.join('.')
        sort_params = [{ field: field, direction: :asc }] if sort_params.blank?

        if sort_params.none? { |param| param[:field] == 'id' || param[:field].end_with?('.id') }
          sort_params << { field: field, direction: sort_params.first[:direction] }
        end
        super sort_params
      end
    end
  end
end
