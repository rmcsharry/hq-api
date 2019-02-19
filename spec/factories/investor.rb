# frozen_string_literal: true

FactoryBot.define do
  factory :investor do
    fund { create :fund }
    mandate { create :mandate }
    bank_account { create :bank_account, owner: mandate }
    primary_owner { create :contact_person, :with_mandate, mandate: mandate }
    contact_address { create :address, owner: primary_owner }
    contact_email { create :email, contact: primary_owner }
    contact_phone { create :phone, contact: primary_owner }
    legal_address { create :address, owner: primary_owner }
    documents { [] }

    investment_date { 1.day.ago }
    amount_total { '100000.0' }

    trait :signed do
      aasm_state { :signed }
      fund_subscription_agreement { build :fund_subscription_agreement, owner: @instance }
    end
  end
end
