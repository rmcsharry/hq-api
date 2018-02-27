FactoryBot.define do
  factory :document do
    name 'Contracts'
    category :contract_hq
    uploader { build(:user, documents: [@instance.presence]) }
    owner { build(:mandate, documents: [@instance.presence]) }
  end
end
