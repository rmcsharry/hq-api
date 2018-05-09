# frozen_string_literal: true

FactoryBot.define do
  factory :document do
    name 'Contracts'
    category :contract_hq
    uploader { create(:user) }
    owner { create(:mandate, documents: [@instance.presence]) }
    after(:build) do |document|
      document.file.attach(
        io: File.open(Rails.root.join('spec', 'fixtures', 'pdfs', 'hqtrust_sample.pdf')),
        filename: 'hqtrust_sample.pdf',
        content_type: 'application/pdf'
      )
    end
  end
end
