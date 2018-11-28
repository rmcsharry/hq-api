# frozen_string_literal: true

# == Schema Information
#
# Table name: funds
#
#  id                            :uuid             not null, primary key
#  duration                      :integer
#  duration_extension            :integer
#  aasm_state                    :string           not null
#  commercial_register_number    :string
#  commercial_register_office    :string
#  currency                      :string
#  name                          :string           not null
#  psplus_asset_id               :string
#  region                        :string
#  strategy                      :string
#  comment                       :text
#  capital_management_company_id :uuid
#  legal_address_id              :uuid
#  primary_contact_address_id    :uuid
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  issuing_year                  :integer
#  type                          :string
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

RSpec.describe Fund::PrivateEquity, type: :model do
  subject { build(:fund_private_equity) }

  describe '#strategy' do
    it { is_expected.to validate_presence_of(:strategy) }
    it { is_expected.to enumerize(:strategy) }
  end
end
