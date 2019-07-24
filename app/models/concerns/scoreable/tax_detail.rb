# frozen_string_literal: true

module Scoreable
  # Score related objects (contct/mandate) when a tax detail changes
  module TaxDetail
    extend ActiveSupport::Concern

    included do
      after_commit :rescore
    end

    def rescore
      contact.calculate_score
    end
  end
end
