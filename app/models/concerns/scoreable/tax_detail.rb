# frozen_string_literal: true

module Scoreable
  # Score related objects (contct/mandate) when a tax detail changes
  module TaxDetail
    extend ActiveSupport::Concern

    included do
      before_save :rescore, if: :has_changes_to_save?
    end

    def rescore
      contact.calculate_score
    end
  end
end
