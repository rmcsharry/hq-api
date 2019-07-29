# frozen_string_literal: true

module Scoreable
  # Score related objects (mandate) when a bank account
  # is FIRST ADDED TO or FINALLY REMOVED FROM the related objects
  module BankAccount
    extend ActiveSupport::Concern

    included do
      after_commit :rescore
    end

    def rescore
      owner.class.skip_callback(:save, :before, :calculate_score, raise: false)
      owner.calculate_score # NOTE if owner is a mandate, then this will also trigger calling factor_owners_into_score
      owner.save!
      owner.class.set_callback(:save, :before, :calculate_score, if: :has_changes_to_save?)
    end
  end
end
