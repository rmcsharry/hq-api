# frozen_string_literal: true

require 'rails_helper'
require 'digits_validator'

RSpec.describe DigitsValidator, type: :model do
  length = 9

  subject do
    # Create a dummy test model class (we do not want the validator test tightly coupled to any specific model)
    Class.new do
      include ActiveModel::Validations
      attr_accessor :exact, :exact_missing
      validates :exact, digits: { exactly: length }
    end.new
  end

  context 'validator for digit-based strings' do
    let(:valid_strings) { %w[012345678 123456789 527931803] }
    let(:invalid_strings) { ['1234567890', 'a', 'a12345678', '0 2345678', '12-654321', '000000000', '1.2345678'] }

    it 'validates format' do
      expect(subject).to allow_values(*valid_strings).for(:exact)
      expect(subject).not_to allow_values(*invalid_strings).for(:exact)
    end

    it 'returns the expected error about contiguous digits' do
      subject.exact = '123'
      subject.valid?
      # "is invalid, expected #{length} contiguous digits"
      expect(subject.errors[:exact]).to match_array("ist ungültig, #{length} zusammenhängende Zahlen erwartet.")
    end
  end
end

RSpec.describe DigitsValidator, type: :model do
  subject do
    # Create a dummy test model class (we do not want the validator test tightly coupled to any specific model)
    Class.new do
      include ActiveModel::Validations
      attr_accessor :exact_missing
      validates :exact_missing, digits: true
    end.new
  end

  context 'validator for digit-based strings' do
    it 'is not used correctly' do
      subject.exact_missing = '123'
      expect { subject.valid? }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
