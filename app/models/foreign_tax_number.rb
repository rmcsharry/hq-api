# == Schema Information
#
# Table name: foreign_tax_numbers
#
#  id            :uuid             not null, primary key
#  tax_number    :string
#  country       :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  tax_detail_id :uuid
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

  belongs_to :tax_detail

  validates :tax_detail, presence: true
  validates :tax_number, presence: true
  validates :country, presence: true

  enumerize :country, in: Address::COUNTRIES
end
