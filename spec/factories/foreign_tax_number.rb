FactoryBot.define do
  factory :foreign_tax_number do
    tax_number '21/815/08150'
    country :at
    tax_detail { build(:tax_detail) }
  end
end
