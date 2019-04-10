# frozen_string_literal: true

# == Schema Information
#
# Table name: list_items
#
#  id            :uuid             not null, primary key
#  list_id       :uuid             not null
#  listable_type :string           not null
#  listable_id   :uuid             not null
#  comment       :text
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_list_items_on_list_id                        (list_id)
#  index_list_items_on_listable_type_and_listable_id  (listable_type,listable_id)
#
# Foreign Keys
#
#  fk_rails_...  (list_id => lists.id)
#

FactoryBot.define do
  factory :list_item, class: 'List::Item' do
    list

    trait :for_contact_organization do
      association :listable, factory: :contact_organization
    end

    trait :for_contact_person do
      association :listable, factory: :contact_person
    end

    trait :for_mandate do
      association :listable, factory: :mandate
    end
  end
end
