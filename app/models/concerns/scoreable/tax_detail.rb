# frozen_string_literal: true

module Scoreable
  # Score related objects (contct/mandate) when a tax detail changes
  module TaxDetail
    extend ActiveSupport::Concern

    included do
      after_commit :rescore_contact
    end

    def rescore_contact
      contact.rescore
    end
  end
end
