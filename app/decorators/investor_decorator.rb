# frozen_string_literal: true

# Defines the decorator for investors
class InvestorDecorator < ApplicationDecorator
  delegate_all

  # Returns a formatted version of the investors
  # total investment amount
  # @return [String]
  def amount_total
    format_currency object.amount_total, object.fund.currency
  end

  # Returns formal salutation for the primary owner or, if present,
  # for the contact person / people
  # @return [String]
  def formal_salutation
    salutation_contacts.map.with_index do |person, i|
      salutation = person.decorate.formal_salutation
      # Downcase first letter of subsequent salutations
      i.positive? ? salutation[0].downcase + salutation[1..-1] : salutation
    end.join(', ')
  end

  # Returns names of associated people relevant for contacting
  # @return [Array<String>]
  def contact_names
    salutation_contacts.map do |person|
      person.decorate.name
    end
  end

  # Returns people relevant for salutations
  # @return [Array<Contact::Person>]
  def salutation_contacts
    [
      contact_salutation_primary_owner ? primary_owner : nil,
      contact_salutation_primary_contact ? primary_contact : nil,
      contact_salutation_secondary_contact ? secondary_contact : nil
    ].compact
  end
end
