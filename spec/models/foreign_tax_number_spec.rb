# frozen_string_literal: true

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

require 'rails_helper'

RSpec.describe ForeignTaxNumber, type: :model do
  it { is_expected.to validate_presence_of(:tax_number) }

  describe '#country' do
    it { is_expected.to validate_presence_of(:country) }
    it { is_expected.to enumerize(:country) }
  end

  describe '#tax_detail' do
    it { is_expected.to belong_to(:tax_detail).required }
  end
end
