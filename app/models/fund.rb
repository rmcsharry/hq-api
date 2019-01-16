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

# Defines the Fund
class Fund < ApplicationRecord
  extend Enumerize
  include AASM

  CURRENCIES = Money::Currency.map(&:iso_code)
  REGIONS = %i[global africa asia australia europe north_america south_america].freeze

  belongs_to :legal_address, class_name: 'Address', optional: true, inverse_of: :owner, autosave: true
  belongs_to :primary_contact_address, class_name: 'Address', optional: true, inverse_of: :owner, autosave: true
  belongs_to :capital_management_company, class_name: 'Contact::Organization', optional: true
  has_many :addresses, as: :owner, inverse_of: :owner, dependent: :destroy
  has_many :bank_accounts, as: :owner, inverse_of: :owner, dependent: :destroy
  has_many :child_versions, class_name: 'Version', as: :parent_item # rubocop:disable Rails/HasManyOrHasOneDependent
  has_many :documents, as: :owner, inverse_of: :owner, dependent: :destroy
  has_many :fund_cashflows, dependent: :destroy
  has_many :investor_cashflows, through: :fund_cashflows
  has_many :fund_reports, dependent: :destroy
  has_many :fund_templates, class_name: 'Document::FundTemplate', as: :owner, inverse_of: :owner, dependent: :destroy
  has_many :investors, dependent: :destroy

  has_paper_trail(
    meta: {
      parent_item_id: :id,
      parent_item_type: 'Fund'
    },
    skip: SKIPPED_ATTRIBUTES
  )

  aasm do
    state :open, initial: true
    state :closed, :liquidated

    event :close do
      transitions from: :open, to: :closed
    end

    event :liquidate do
      transitions from: :closed, to: :liquidated
    end
  end

  validates :type, presence: true
  validates :commercial_register_number, presence: true, if: :commercial_register_office
  validates :commercial_register_office, presence: true, if: :commercial_register_number
  validates :issuing_year, presence: true
  validates :name, presence: true
  validates :psplus_asset_id, length: { maximum: 15 }
  validates :strategy, presence: true

  enumerize :currency, in: CURRENCIES
  enumerize :region, in: REGIONS, scope: true

  alias_attribute :state, :aasm_state
  alias_attribute :fund_type, :type

  def holdings_last_update_at
    # TODO: Implement actual logic
    Time.zone.now
  end

  def total_signed_amount
    investors.signed.sum(&:amount_total)
  end

  def total_called_amount
    investor_cashflows.sum(&:capital_call_total_amount)
  end

  def total_open_amount
    total_signed_amount - total_called_amount + total_recallable_amount
  end

  def total_recallable_amount
    investor_cashflows.sum(&:distribution_recallable_amount)
  end

  def total_distributions_amount
    investor_cashflows.sum(&:distribution_total_amount)
  end

  def tvpi
    # TODO: Implement actual logic
    1
  end

  def dpi
    # TODO: Implement actual logic
    1
  end

  def irr
    # TODO: Implement actual logic
    1
  end

  def to_s
    name
  end
end
