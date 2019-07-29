# frozen_string_literal: true

module Scoreable
  # Concern to provide scoring rules and logic for a mandate
  module MandateMember
    extend ActiveSupport::Concern

    included do
      after_commit :rescore
    end

    def rescore
      mandate.class.skip_callback(:save, :before, :calculate_score, raise: false)
      mandate.calculate_score
      mandate.save!
      mandate.factor_owners_into_score
      mandate.class.set_callback(:save, :before, :calculate_score, if: :has_changes_to_save?)
    end
  end
end
