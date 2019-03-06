# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += %i[
  addition
  bank-account-number
  bank-routing-number
  bic
  city
  comment
  commercial-register-number
  commercial-register-office
  confirmation-token
  date-of-birth
  date-of-death
  de-tax-id
  de-tax-number
  description
  email
  encrypted-password
  eu-vat-number
  ews-user-id
  first-name
  iban
  invitation-token
  last-name
  legal-entity-identifier
  maiden-name
  organization-name
  owner-name
  password
  place-of-birth
  postal-code
  reset-password-token
  state
  street-and-number
  tax-number
  unconfirmed-email
  unlock-token
  us-tax-number
]
