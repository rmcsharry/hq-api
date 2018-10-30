# frozen_string_literal: true

module V1
  # Defines the BankAccount resource for the API
  class BankAccountResource < BaseResource
    attributes :account_type, :owner_name, :bank_account_number, :bank_routing_number, :iban, :bic, :currency

    has_one :owner, polymorphic: true
    has_one :bank, class_name: 'Contact'

    filter :owner_id

    sort :"bank.name", apply: lambda { |records, direction, _context|
      records.joins(:bank).order("contacts.organization_name #{direction}")
    }

    # TODO: Can be removed when this issue is solved: https://github.com/cerebris/jsonapi-resources/issues/1160
    def _replace_polymorphic_to_one_link(relationship_type, key_value, key_type, _options)
      relationship = self.class._relationships[relationship_type.to_sym]

      send("#{relationship.foreign_key}=", type: self.class.model_name_for_type(key_type), id: key_value)
      @save_needed = true

      :completed
    end
  end
end
