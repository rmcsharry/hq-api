# frozen_string_literal: true

# == Schema Information
#
# Table name: bank_accounts
#
#  account_type            :string
#  alternative_investments :boolean          default(FALSE), not null
#  bank_account_number     :string
#  bank_id                 :uuid
#  bank_routing_number     :string
#  bic                     :string
#  created_at              :datetime         not null
#  currency                :string
#  iban                    :string
#  id                      :uuid             not null, primary key
#  owner_id                :uuid             not null
#  owner_name              :string
#  owner_type              :string           not null
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_bank_accounts_on_bank_id                  (bank_id)
#  index_bank_accounts_on_owner_type_and_owner_id  (owner_type,owner_id)
#
# Foreign Keys
#
#  fk_rails_...  (bank_id => contacts.id)
#

# Defines the Bank Account of a Mandate or Fund
class BankAccount < ApplicationRecord
  extend Enumerize

  CURRENCIES = Money::Currency.map(&:iso_code)
  ACCOUNT_TYPE = %i[currency_account payments_account settlement_account].freeze

  belongs_to :owner, polymorphic: true, inverse_of: :bank_accounts
  belongs_to :bank, class_name: 'Contact::Organization', inverse_of: :bank_accounts

  has_paper_trail(
    meta: {
      parent_item_id: :owner_id,
      parent_item_type: :owner_type
    },
    skip: SKIPPED_ATTRIBUTES
  )

  before_validation :normalize_iban
  before_validation :normalize_bic

  validates :account_type, presence: true
  validates :owner, presence: true
  validates :currency, presence: true

  validates :iban, presence: true, if: -> { bic.present? }, iban: true
  validates :bic, presence: true, if: -> { iban.present? }
  validates :bank_account_number, presence: true, if: -> { bank_routing_number.present? }
  validates :bank_routing_number, presence: true, if: -> { bank_account_number.present? }

  validate :iban_or_bank_number_present

  enumerize :account_type, in: ACCOUNT_TYPE, scope: true
  enumerize :currency, in: CURRENCIES

  def iban_or_bank_number_present
    return if (iban.present? && bank_account_number.blank?) || (iban.blank? && bank_account_number.present?)

    errors.add(:iban_bank_account_number, 'exactly one of IBAN or bank account number must be set')
  end

  def bank_name
    bank&.organization_name
  end

  private

  def normalize_iban
    self.iban = iban.upcase.gsub(/\s+/, '') if iban.present?
  end

  def normalize_bic
    self.bic = bic.upcase.gsub(/\s+/, '') if bic.present?
  end
end
