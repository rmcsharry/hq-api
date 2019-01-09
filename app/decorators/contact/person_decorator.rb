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
  end
end
