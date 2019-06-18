# frozen_string_literal: true

module JSONAPI
  # formats fractional decimals to whole decimals
  class PercentValueFormatter < ValueFormatter
    class << self
      def format(raw_value)
        (raw_value * 100).as_json
      end

      def unformat(value)
        value / 100
      end
    end
  end
end
