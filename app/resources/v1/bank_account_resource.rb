# frozen_string_literal: true

module V1
  # Defines the BankAccount resource for the API
  class BankAccountResource < BaseResource
    attributes :account_type, :owner_name, :bank_account_number, :bank_routing_number, :iban, :bic, :currency,
               :alternative_investments

    has_one :owner, polymorphic: true
    has_one :bank, class_name: 'Contact'

    filters(
      :alternative_investments,
      :owner_id
    )

    sort :"bank.name", apply: lambda { |records, direction, _context|
      records.left_joins(:bank).order("contacts.organization_name #{direction}")
    }

    class << self
      def records(options)
        super.preload(:owner, :bank)
      end
    end
  end
end
