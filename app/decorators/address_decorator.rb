# frozen_string_literal: true

# Defines the decorator for addresses
class AddressDecorator < Draper::Decorator
  delegate_all

  # Returns address formatted for letters
  # @return [String]
  def letter_address(addressee)
    [
      organization_name,
      addressee,
      street_and_number,
      addition,
      postal_code,
      city,
      localized_country_name
    ].compact.flatten.join("\n")
  end

  private

  def localized_country_name
    Carmen::Country.alpha_2_coded(country).name
  end
end
