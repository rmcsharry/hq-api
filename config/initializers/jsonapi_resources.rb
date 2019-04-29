# frozen_string_literal: true

JSONAPI.configure do |config|
  config.default_paginator = :paged
  config.default_page_size = 10
  config.maximum_page_size = 1000
  config.top_level_meta_include_record_count = true
  config.top_level_meta_include_page_count = true
  config.resource_key_type = :uuid

  config.default_processor_klass = JSONAPI::Authorization::AuthorizingProcessor
  config.exception_class_whitelist = [Pundit::NotAuthorizedError]
  config.whitelist_all_exceptions = true
end

JSONAPI::Authorization.configure do |config|
  config.pundit_user = :pundit_user
end

module JSONAPI
  # JSONAPI::Resources extension of the Resource class
  class Resource
    class << self
      # rubocop:disable Metrics/AbcSize
      def resource_klass_for(type)
        type = type.underscore
        type = _model_hints[type] if _model_hints && _model_hints[type]
        type_with_module = type.start_with?(module_path) ? type : module_path + type

        resource_name = _resource_name_from_type(type_with_module)
        resource = resource_name.safe_constantize if resource_name
        if resource.nil?
          raise NameError, "JSONAPI: Could not find resource '#{type}'. (Class #{resource_name} not found)"
        end

        resource
      end
      # rubocop:enable Metrics/AbcSize

      def _lookup_association_chain(model_names)
        associations = []
        model_names.inject do |prev, current|
          association = prev.classify.constantize.reflect_on_all_associations.detect do |assoc|
            assoc.name.to_s.casecmp(current).zero?
          end
          associations << association
          association.class_name
        end

        associations
      end
    end
  end

  module ActiveRelationResourceFinder
    # JSONAPI::Resources extension of the ClassMethods module
    module ClassMethods
      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/PerceivedComplexity
      def find_related_monomorphic_fragments(source_rids, relationship, included_key, options = {})
        source_ids = source_rids.collect(&:id)

        context = options[:context]

        records = records(context: context)
        related_klass = relationship.resource_klass

        records, table_alias = apply_join(records, relationship, options)

        sort_criteria = []
        options[:sort_criteria].try(:each) do |sort|
          field = sort[:field].to_s == 'id' ? related_klass._primary_key : sort[:field]
          sort_criteria << { field: concat_table_field(table_alias, field),
                             direction: sort[:direction] }
        end

        order_options = related_klass.construct_order_options(sort_criteria, table_alias)

        paginator = options[:paginator]

        # TODO: Remove count check. Currently pagination isn't working with multiple source_rids (i.e. it only works
        # for show relationships, not related includes).
        if paginator && source_rids.count == 1 && !included_key
          records = related_klass.apply_pagination(records, paginator, order_options)
        end

        records = related_klass.apply_basic_sort(records, order_options, context: context)

        filters = options.fetch(:filters, {})

        primary_key_field = concat_table_field(_table_name, _primary_key)

        filters[primary_key_field] = source_ids

        filter_options = options.dup
        filter_options[:table_alias] = table_alias

        records = related_klass.apply_filters(records, filters, filter_options)

        pluck_fields = [
          primary_key_field,
          concat_table_field(table_alias, related_klass._primary_key)
        ]

        cache_field = related_klass.attribute_to_model_field(:_cache_field) if options[:cache]
        pluck_fields << concat_table_field(table_alias, cache_field[:name]) if cache_field

        model_fields = {}
        attributes = options[:attributes]
        attributes.try(:each) do |attribute|
          model_field = related_klass.attribute_to_model_field(attribute)
          model_fields[attribute] = model_field
          pluck_fields << concat_table_field(table_alias, model_field[:name])
        end

        rows = records.pluck(*pluck_fields)

        relation_name = relationship.name.to_sym

        related_fragments = {}

        rows.each do |row|
          next if row[1].nil?

          rid = JSONAPI::ResourceIdentity.new(related_klass, row[1])
          related_fragments[rid] ||= { identity: rid, related: { relation_name => [] } }

          attributes_offset = 2

          if cache_field
            related_fragments[rid][:cache] = cast_to_attribute_type(row[attributes_offset], cache_field[:type])
            attributes_offset += 1
          end

          related_fragments[rid][:attributes] = {} unless model_fields.empty?
          model_fields.each_with_index do |k, idx|
            related_fragments[rid][:attributes][k[0]] = cast_to_attribute_type(
              row[idx + attributes_offset], k[1][:type]
            )
          end

          related_fragments[rid][:related][relation_name] << JSONAPI::ResourceIdentity.new(self, row[0])
        end

        related_fragments
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/PerceivedComplexity
    end
  end

  # JSONAPI::Resources extension of the Relationship class
  class Relationship
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Style/CaseEquality
    def self.polymorphic_types(name)
      @poly_hash ||= {}.tap do |hash|
        ObjectSpace.each_object do |klass|
          next if !(Module === klass) || klass.name.nil? || !(ActiveRecord::Base > klass)

          klass.reflect_on_all_associations(:has_many).select { |r| r.options[:as] }.each do |reflection|
            (hash[reflection.options[:as]] ||= []) << klass.name.underscore
          end
        end
      end
      @poly_hash[name.to_sym]
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Style/CaseEquality
  end
end
