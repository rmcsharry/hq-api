FactoryBot.define do
  factory :document do
    name 'Contracts'
    category :contract_hq
    uploader { create(:user) }
    owner { create(:mandate, documents: [@instance.presence]) }
  end
end
