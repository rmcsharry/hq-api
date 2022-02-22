# frozen_string_literal: true

module Scoreable
  # Score related objects (mandate) when a bank account
  # is FIRST ADDED TO or FINALLY REMOVED FROM the related objects
  module BankAccount
    extend ActiveSupport::Concern

    included do
      after_commit :rescore_owner
    end

    def rescore_owner
      return if owner.bank_accounts.count > 1

      owner.rescore # NOTE since owner is a mandate, this will trigger calling factor_owners_into_score
    end
  end
end
