# frozen_string_literal: true

FactoryBot.define do
  factory :investor do
    fund { create :fund }
    mandate { create :mandate }
    bank_account { create :bank_account }
    contact_address { create :address }
    contact_email { create :email }
    contact_phone { create :phone }
    legal_address { create :address }
    primary_owner { create :contact_person }
    documents { [] }

    investment_date { 1.day.ago }
    amount_total { '100000.0' }

    trait :signed do
      aasm_state { :signed }
      fund_subscription_agreement { build :fund_subscription_agreement, owner: @instance }
    end
  end
end
