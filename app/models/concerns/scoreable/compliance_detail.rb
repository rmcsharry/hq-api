# frozen_string_literal: true

module Scoreable
  # Score related objects (contct/mandate) when a tax detail changes
  module ComplianceDetail
    extend ActiveSupport::Concern

    included do
      after_commit :rescore_contact
    end

    def rescore_contact
      contact.calculate_score
      contact.save!
    end
  end
end
