FactoryBot.define do
  factory :mandate_member, class: MandateMember do
    member_type :owner
    contact { build(:contact_person) }
    mandate { build(:mandate) }
  end
end
