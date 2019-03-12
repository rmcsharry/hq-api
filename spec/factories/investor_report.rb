# frozen_string_literal: true

FactoryBot.define do
  factory :investor_report do
    fund_report { create :fund_report }
    investor { create :investor }
  end
end
