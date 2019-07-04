# frozen_string_literal: true

# Defines the decorator for bank accounts
class BankAccountDecorator < ApplicationDecorator
  delegate_all

  # Returns the IBAN formatted with spaces
  # Example: "DE68 2105 0170 0012 3456 78"
  # @return [String]
  def formatted_iban
    Ibanizator.iban_from_string(iban).formatted_iban_string
  end
end
