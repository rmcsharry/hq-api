# frozen_string_literal: true

# Concern to find all enumerable attributes of siblings
module ExportableAttributes
  extend ActiveSupport::Concern

  class_methods do
    def exportable_attributes
      parent.respond_to?(:exportable_attributes) ? parent.exportable_attributes : enumerized_attributes
    end
  end
end
