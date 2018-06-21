# frozen_string_literal: true

module V1
  # Defines the BankAccount resource for the API
  class BankAccountResource < BaseResource
    attributes :account_type, :owner, :bank_account_number, :bank_routing_number, :iban, :bic, :currency

    has_one :mandate
    has_one :bank, class_name: 'Contact'

    filter :mandate_id
  end
end
