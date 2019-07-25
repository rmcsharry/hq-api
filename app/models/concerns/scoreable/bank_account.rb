# frozen_string_literal: true

module Scoreable
  # Score related objects (mandate) when a bank account
  # is FIRST ADDED TO or FINALLY REMOVED FROM the related objects
  module BankAccount
    extend ActiveSupport::Concern
  end
end
