# frozen_string_literal: true

FactoryBot.define do
  factory :investor do
    fund { create :fund }
    mandate { create :mandate, :with_owner }
    bank_account { create :bank_account, owner: mandate }
    documents { [] }

    investment_date { 1.day.ago }
    amount_total { '100000.0' }

    trait :signed do
      aasm_state { :signed }
      fund_subscription_agreement { build :fund_subscription_agreement, owner: @instance }
    end
  end
end
