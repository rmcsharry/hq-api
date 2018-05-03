# frozen_string_literal: true

# Generates and modifies IBANs
class IbanGenerator
  class << self
    # Returns a random IBAN
    def random_iban(country_code: 'DE')
      sanitize_iban(dirty_iban: Faker::Bank.iban(country_code))
    end

    # Cleans up a given IBAN with the correct checksum
    def sanitize_iban(dirty_iban:)
      country_code = dirty_iban[0..1].upcase.to_sym
      length = Ibanizator::Iban::LENGTHS[country_code]
      reminder = '0' + integerize(iban: dirty_iban, length: length).to_s
      dirty_iban[0..1] + reminder[-2..-1] + dirty_iban[4..length - 1]
    end

    private

    def integerize(iban:, length:)
      val = "#{iban[4..length - 1]}#{iban[0..1]}" + '00'
      chksum = val.gsub(/[A-Z]/) do |match|
        match.ord - 'A'.ord + 10
      end.to_i
      98 - chksum % 97
    end
  end
end
