# frozen_string_literal: true

FactoryBot.define do
  factory :foreign_tax_number do
    tax_number '21/815/08150'
    country 'AT'
    tax_detail { build(:tax_detail) }
  end
end
