# frozen_string_literal: true

# == Schema Information
#
# Table name: foreign_tax_numbers
#
#  country       :string
#  created_at    :datetime         not null
#  id            :uuid             not null, primary key
#  tax_detail_id :uuid
#  tax_number    :string
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_foreign_tax_numbers_on_tax_detail_id  (tax_detail_id)
#
# Foreign Keys
#
#  fk_rails_...  (tax_detail_id => tax_details.id)
#

# Defines the Forein Tax Number of a Tax Detail
class ForeignTaxNumber < ApplicationRecord
  extend Enumerize
  strip_attributes only: :tax_number, collapse_spaces: true

  belongs_to :tax_detail

  has_paper_trail(
    meta: {
      parent_item_id: proc { |foreign_tax_number| foreign_tax_number.tax_detail.contact_id },
      parent_item_type: 'Contact'
    },
    skip: SKIPPED_ATTRIBUTES
  )

  validates :tax_number, presence: true
  validates :country, presence: true

  enumerize :country, in: Address::COUNTRIES
end
