# frozen_string_literal: true

class Contact
  # Defines the decorator for natural persons
  class PersonDecorator < ContactDecorator
    delegate_all

    # Returns the Person's full name
    # @return [String]
    def name(with_first_name: true)
      [
        professional_title_text,
        with_first_name ? first_name : nil,
        nobility_title_text,
        last_name
      ].compact.join(' ')
    end

    # Returns the Person's full name is list style
    # @return [String]
    def name_list
      salutation = [professional_title_text, first_name, nobility_title_text].compact.join(' ')
      "#{last_name}, #{salutation}"
    end

    # Returns formal salutation for the Person including
    # their full name and gender
    # @return [String]
    def formal_salutation(with_first_name: true)
      is_female = gender == :female
      salutation_prefix = is_female ? 'geehrte' : 'geehrter'
      salutation = is_female ? 'Frau' : 'Herr'
      "Sehr #{salutation_prefix} #{salutation} #{name(with_first_name: with_first_name)}"
    end

    # Returns next birthday
    # @return [Date]
    def next_birthday
      return nil unless date_of_birth

      now = Time.zone.now
      birthday_year = next_birthday_this_year? ? now.year : now.year + 1
      Date.new(birthday_year, date_of_birth.month, date_of_birth.day)
    end

    # Returns gender for addresses
    def gender_for_address
      gender == :male ? 'Herrn' : 'Frau'
    end

    # Returns the name with gender for addresses, i.e. Herrn Max Mustermann or Frau Maria Mustermann
    # @return [String]
    def name_with_gender
      "#{gender_for_address} #{name}"
    end

    private

    def next_birthday_this_year?
      now = Time.zone.now

      date_of_birth.month > now.month ||
        date_of_birth.change(year: now.year) >= now
    end
  end
end
