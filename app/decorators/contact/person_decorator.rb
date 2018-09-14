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
  end
end
