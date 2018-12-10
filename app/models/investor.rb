# frozen_string_literal: true

# == Schema Information
#
# Table name: investors
#
#  id                 :uuid             not null, primary key
#  fund_id            :uuid
#  mandate_id         :uuid
#  legal_address_id   :uuid
#  contact_address_id :uuid
#  contact_email_id   :uuid
#  contact_phone_id   :uuid
#  bank_account_id    :uuid
#  primary_owner_id   :uuid
#  aasm_state         :string           not null
#  investment_date    :datetime
#  amount_total       :decimal(20, 2)
#  decimal            :decimal(20, 2)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_investors_on_fund_id     (fund_id)
#  index_investors_on_mandate_id  (mandate_id)
#
# Foreign Keys
#
#  fk_rails_...  (bank_account_id => bank_accounts.id)
#  fk_rails_...  (contact_address_id => addresses.id)
#  fk_rails_...  (contact_email_id => contact_details.id)
#  fk_rails_...  (contact_phone_id => contact_details.id)
#  fk_rails_...  (fund_id => funds.id)
#  fk_rails_...  (legal_address_id => addresses.id)
#  fk_rails_...  (mandate_id => mandates.id)
#  fk_rails_...  (primary_owner_id => contacts.id)
#

# Defines the Investor
class Investor < ApplicationRecord
  include AASM

  belongs_to :bank_account, autosave: true
  belongs_to :contact_address, class_name: 'Address', autosave: true
  belongs_to :contact_email, class_name: 'ContactDetail::Email', autosave: true
  belongs_to :contact_phone, class_name: 'ContactDetail::Phone', autosave: true
  belongs_to :fund, inverse_of: :investors, autosave: true
  belongs_to :legal_address, class_name: 'Address', autosave: true
  belongs_to :mandate, inverse_of: :investments, autosave: true
  belongs_to :primary_owner, class_name: 'Contact', autosave: true
  has_and_belongs_to_many :fund_reports, -> { distinct }
  has_many :documents, as: :owner, inverse_of: :owner, dependent: :destroy
  has_many :investor_cashflows, dependent: :nullify
  has_one :fund_subscription_agreement,
          -> { where(category: :fund_subscription_agreement) },
          class_name: 'Document::FundSubscriptionAgreement',
          inverse_of: :owner,
          as: :owner

  has_paper_trail(
    meta: {
      parent_item_id: :fund_id,
      parent_item_type: 'Fund'
    },
    skip: SKIPPED_ATTRIBUTES
  )

  aasm do
    state :created, initial: true
    state :signed

    event :sign do
      before do
        set_investment_date
      end

      transitions from: :created, to: :signed
    end
  end

  alias_attribute :state, :aasm_state

  validates :fund, presence: true
  validates :mandate, presence: true
  validates :amount_total, presence: true
  validate :attributes_in_signed_state

  def amount_called
    investor_cashflows.sum(&:capital_call_total_amount)
  end

  def amount_open
    amount_total - amount_called
  end

  def current_value
    # TODO: Implement actual logic
    -1
  end

  def amount_total_distribution
    investor_cashflows.sum(&:distribution_total_amount)
  end

  def tvpi
    # TODO: Implement actual logic
    -1
  end

  def dpi
    # TODO: Implement actual logic
    -1
  end

  def irr
    # TODO: Implement actual logic
    -1
  end

  private

  # Validates presence of investment_date and fund_subscription_agreement if state is `signed`
  # @return [void]
  def attributes_in_signed_state
    return unless signed?

    error_message = 'must be present if investor is signed'
    errors.add(:investment_date, error_message) if investment_date.nil?
    errors.add(:fund_subscription_agreement, error_message) if fund_subscription_agreement.nil?
  end

  def set_investment_date
    self.investment_date = Time.zone.now if investment_date.nil?
  end
end
