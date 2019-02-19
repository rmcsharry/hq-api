# frozen_string_literal: true

# Service for making jsonapi response documents compatible
# with spreadsheet file generation
class FormatResponseDocumentService < ApplicationService
  def self.call(contents)
    instance = new contents
    instance.call
  end

  def initialize(contents)
    @contents = contents
    @headers = {}
    @worksheets = {}
  end

  def call
    resources.each do |resource|
      # resource is {} in case the object is not available due to auhorization restrictions (e.g. policies)
      next if resource.empty?

      type = build_type(resource['type'])
      @worksheets[type] ||= []
      @worksheets[type] << parse_resource(resource, type)
    end

    @worksheets.each do |type, worksheet|
      worksheet.unshift(@headers[type].values.flatten)
    end
  end

  private

  def resources
    data = @contents['data']
    data = data.is_a?(Array) ? data : [data]
    @resources ||= [*data, *@contents['included']]
  end

  def build_type(raw_type)
    raw_type.underscore.camelize
  end

  def parse_resource(resource, type)
    attributes = resource.dig('attributes') || {}
    meta = resource.dig('meta') || {}
    relations = resource.dig('relationships') || {}

    headers = @headers[type] ||= parse_headers(attributes, meta, relations)

    [
      resource['id'],
      *parse_attributes(attributes, headers),
      *parse_meta(meta, headers),
      *parse_relations(type, resource, relations, headers)
    ]
  end

  def parse_headers(attributes, meta, relations)
    attribute_names = ['id', *attributes.keys]
    relation_types = relations.map do |type, _relation|
      attribute_names -= [type]
      type
    end.compact

    {
      attribute_names: attribute_names,
      meta_names: meta.keys,
      relation_types: relation_types
    }
  end

  def parse_attributes(attributes, headers)
    headers[:attribute_names].drop(1).map do |attribute_name|
      attributes[attribute_name]
    end
  end

  def parse_meta(meta, headers)
    headers[:meta_names].map do |meta_name|
      meta[meta_name]
    end
  end

  def parse_relations(resource_type, resource, relations, headers)
    headers[:relation_types].map do |relation_type|
      relation = relations.dig(relation_type, 'data')
      if relation.is_a?(Hash)
        relation['id']
      elsif relation.is_a?(Array)
        parse_to_many_relation(resource_type, resource, relation_type, relation)
      end
    end
  end

  def parse_to_many_relation(resource_type, resource, raw_relation_type, relation)
    relation_type = build_type(raw_relation_type)
    worksheet_name = "#{resource_type}_#{relation_type}"

    @worksheets[worksheet_name] ||= []
    @headers[worksheet_name] ||= {
      attribute_names: ["#{resource_type}-id", "#{relation_type}-id"]
    }

    relation.map do |relation_resource|
      @worksheets[worksheet_name] << [resource['id'], relation_resource['id']]
      relation_resource['id']
    end.join(',')
  end
end
