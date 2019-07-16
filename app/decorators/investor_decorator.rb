# frozen_string_literal: true

# Defines the decorator for investors
class InvestorDecorator < ApplicationDecorator
  delegate_all

  # Returns a formatted version of the investors
  # total investment amount
  # @return [String]
  def amount_total
    format_currency(value: object.amount_total, currency: object.fund.currency, no_cents: true)
  end

  # Returns formal salutation for the primary owner or, if present,
  # for the contact person / people
  # @return [String]
  def formal_salutation(with_first_name: true)
    relevant_contacts(contacts: salutation_contacts).map.with_index do |contact, i|
      salutation = contact.decorate.formal_salutation(with_first_name: with_first_name)
      # Downcase first letter of subsequent salutations
      i.positive? ? salutation[0].downcase + salutation[1..-1] : salutation
    end.join(', ')
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

  private

  def relevant_contacts(contacts:)
    person_contacts = contacts.select { |contact| contact.is_a? Contact::Person }
    # In case there are no person contacts, we need to address "Sehr geehrte Damen und Herren" only once
    person_contacts.any? ? person_contacts : [salutation_contacts.first].compact
  end
end
