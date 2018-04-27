# frozen_string_literal: true

module V1
  # Defines the BankAccounts controller
  class BankAccountsController < ApplicationController
    before_action :authenticate_user!
  end
end
