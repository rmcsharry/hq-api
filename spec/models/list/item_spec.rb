# frozen_string_literal: true

# == Schema Information
#
# Table name: list_items
#
#  comment       :text
#  created_at    :datetime         not null
#  id            :uuid             not null, primary key
#  list_id       :uuid             not null
#  listable_id   :uuid             not null
#  listable_type :string           not null
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

require 'rails_helper'

RSpec.describe List::Item, type: :model do
  it do
    expect(described_class::LISTABLE_TYPES).to eql(
      %w[
        Contact
        Mandate
      ]
    )
  end

  it { is_expected.to belong_to(:list).inverse_of(:items) }
  it { is_expected.to belong_to(:listable).inverse_of(:list_items) }

  it { is_expected.to validate_presence_of(:list) }
  it { is_expected.to validate_presence_of(:listable_id) }
  it {
    expect(create(:list_item, listable: Contact.create!))
      .to validate_uniqueness_of(:listable_id).case_insensitive.scoped_to(%i[list_id listable_type])
  }
  it { is_expected.to validate_inclusion_of(:listable_type).in_array(described_class::LISTABLE_TYPES) }
  it { is_expected.to validate_presence_of(:listable_type) }
end
