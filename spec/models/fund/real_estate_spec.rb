# frozen_string_literal: true

# == Schema Information
#
# Table name: funds
#
#  aasm_state                                :string           not null
#  capital_management_company_id             :uuid
#  comment                                   :text
#  commercial_register_number                :string
#  commercial_register_office                :string
#  created_at                                :datetime         not null
#  currency                                  :string
#  de_central_bank_id                        :string
#  de_foreign_trade_regulations_id           :string
#  duration                                  :integer
#  duration_extension                        :integer
#  global_intermediary_identification_number :string
#  id                                        :uuid             not null, primary key
#  issuing_year                              :integer
#  legal_address_id                          :uuid
#  name                                      :string           not null
#  primary_contact_address_id                :uuid
#  psplus_asset_id                           :string
#  region                                    :string
#  strategy                                  :string
#  tax_id                                    :string
#  tax_office                                :string
#  type                                      :string
#  updated_at                                :datetime         not null
#  us_employer_identification_number         :string
#
# Indexes
#
#  index_funds_on_capital_management_company_id  (capital_management_company_id)
#  index_funds_on_legal_address_id               (legal_address_id)
#  index_funds_on_primary_contact_address_id     (primary_contact_address_id)
#
# Foreign Keys
#
#  fk_rails_...  (capital_management_company_id => contacts.id)
#  fk_rails_...  (legal_address_id => addresses.id)
#  fk_rails_...  (primary_contact_address_id => addresses.id)
#

require 'rails_helper'

RSpec.describe Fund::RealEstate, type: :model do
  subject { build(:fund_real_estate) }

  describe '#strategy' do
    it { is_expected.to validate_presence_of(:strategy) }
    it { is_expected.to enumerize(:strategy) }
  end
end
