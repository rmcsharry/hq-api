# frozen_string_literal: true

class Contact
  # Defines the decorator for natural persons
  class PersonDecorator < ContactDecorator
    delegate_all

    # Returns the Person's full name
    # @return [String]
    def name
      "#{first_name} #{last_name}"
    end

    # Returns the Person's full name is list style
    # @return [String]
    def name_list
      "#{last_name}, #{first_name}"
    end

    # Returns formal salutation for the Person including
    # their full name and gender
    # @return [String]
    def formal_salutation
      is_female = gender == :female
      salutation_prefix = is_female ? 'geehrte' : 'geehrter'
      salutation = is_female ? 'Frau' : 'Herr'
      "Sehr #{salutation_prefix} #{salutation} #{name}"
    end

    # Returns next birthday
    # @return [Date]
    def next_birthday
      return nil unless date_of_birth

      now = Time.zone.now
      birthday_year = next_birthday_this_year? ? now.year : now.year + 1
      Date.new(birthday_year, date_of_birth.month, date_of_birth.day)
    end

    private

    def next_birthday_this_year?
      now = Time.zone.now

      date_of_birth.month > now.month ||
        date_of_birth.change(year: now.year) >= now
    end
  end
end
