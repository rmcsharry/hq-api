# frozen_string_literal: true

module Scoreable
  # Score related objects (contct/mandate) when a tax detail changes
  module ComplianceDetail
    extend ActiveSupport::Concern

    included do
      after_commit :rescore
    end

    def rescore
      contact.class.skip_callback(:save, :before, :calculate_score, raise: false)
      contact.calculate_score
      contact.save!
      contact.class.set_callback(:save, :before, :calculate_score, if: :has_changes_to_save?)
    end
  end
end
