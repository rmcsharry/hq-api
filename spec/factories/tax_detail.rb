FactoryBot.define do
  factory :tax_detail, class: TaxDetail do
    de_tax_number '21/815/08150'
    de_tax_id '12345678911'
    de_tax_office 'Finanzamt Berlin-Charlottenburg'
    contact { build(:contact, tax_detail: @instance.presence) }
  end
end
