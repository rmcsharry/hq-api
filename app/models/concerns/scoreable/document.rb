# frozen_string_literal: true

module Scoreable
  # Score related objects (contct/mandate) when a document of a given type
  # is FIRST ADDED TO or FINALLY REMOVED FROM the related objects
  module Document
    extend ActiveSupport::Concern
  end
end
