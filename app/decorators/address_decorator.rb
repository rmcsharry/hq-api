# frozen_string_literal: true

# Defines the decorator for addresses
class AddressDecorator < Draper::Decorator
  delegate_all

  # Returns address formatted for letters
  # @return [String]
  def letter_address(addressees:)
    [
      organization_name,
      styled_addressees(addressees: addressees),
      street_and_number,
      addition,
      "#{postal_code} #{city}",
      localized_country_name
    ].compact.flatten.join("\n")
  end

  private

  def localized_country_name
    country != 'DE' ? Carmen::Country.alpha_2_coded(country).name : nil # do not display Germany as country name
  end

  # If the contact address contains only one person and no company, show the gender in a separate row from the name
  def styled_addressees(addressees:)
    if organization_name.blank? && addressees.count == 1
      [addressees.first.decorate.gender_for_address, addressees.first.decorate.name]
    else
      addressees.map { |addressee| addressee.decorate.name_with_gender }
    end
  end
end
