# frozen_string_literal: true

# == Schema Information
#
# Table name: bank_accounts
#
#  id                  :uuid             not null, primary key
#  account_type        :string
#  owner               :string
#  bank_account_number :string
#  bank_routing_number :string
#  iban                :string
#  bic                 :string
#  currency            :string
#  mandate_id          :uuid
#  bank_id             :uuid
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_bank_accounts_on_bank_id     (bank_id)
#  index_bank_accounts_on_mandate_id  (mandate_id)
#
# Foreign Keys
#
#  fk_rails_...  (bank_id => contacts.id)
#  fk_rails_...  (mandate_id => mandates.id)
#

# Defines the Bank Account of a Mandate
class BankAccount < ApplicationRecord
  extend Enumerize

  CURRENCIES = Money::Currency.all.map(&:iso_code)

  belongs_to :mandate
  belongs_to :bank, class_name: 'Contact::Organization', inverse_of: :bank_accounts

  validates :account_type, presence: true
  validates :owner, presence: true
  validates :currency, presence: true

  validates :iban, presence: true, if: -> { bic.present? }, iban: true
  validates :bic, presence: true, if: -> { iban.present? }
  validates :bank_account_number, presence: true, if: -> { bank_routing_number.present? }
  validates :bank_routing_number, presence: true, if: -> { bank_account_number.present? }

  validate :iban_or_bank_number_present

  enumerize :account_type, in: %i[currency_account settlement_account], scope: true
  enumerize :currency, in: CURRENCIES

  def iban_or_bank_number_present
    return if iban.present? || bank_account_number.present?
    errors.add(:iban_bank_account_number, "can't be blank together")
  end

  def bank_name
    bank&.organization_name
  end
end
