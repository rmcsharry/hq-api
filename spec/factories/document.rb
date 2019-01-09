# frozen_string_literal: true

FactoryBot.define do
  factory :document do
    name { 'Contracts' }
    category { :contract_hq }
    uploader { create(:user) }
    owner { create(:mandate, documents: [@instance.presence]) }
    after(:build) do |document|
      document.file.attach(
        io: File.open(Rails.root.join('spec', 'fixtures', 'pdfs', 'hqtrust_sample.pdf')),
        filename: 'hqtrust_sample.pdf',
        content_type: 'application/pdf'
      )
    end

    factory :fund_template_document, class: Document::FundTemplate do
      name { 'fund_capital_call_template.pdf' }
      category { :fund_capital_call_template }
      owner { create(:fund, documents: [@instance.presence]) }
    end

    factory :fund_subscription_agreement, class: Document::FundSubscriptionAgreement do
      name { 'fund_subscription_agreement.pdf' }
      category { :fund_subscription_agreement }
      owner { create(:investor, documents: [@instance.presence], state: :signed) }
    end
  end
end
