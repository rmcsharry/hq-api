# frozen_string_literal: true

# == Schema Information
#
# Table name: investors
#
#  aasm_state             :string           not null
#  amount_total           :decimal(20, 2)
#  bank_account_id        :uuid
#  capital_account_number :string
#  created_at             :datetime         not null
#  fund_id                :uuid
#  id                     :uuid             not null, primary key
#  investment_date        :datetime
#  mandate_id             :uuid
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_investors_on_fund_id     (fund_id)
#  index_investors_on_mandate_id  (mandate_id)
#
# Foreign Keys
#
#  fk_rails_...  (bank_account_id => bank_accounts.id)
#  fk_rails_...  (fund_id => funds.id)
#  fk_rails_...  (mandate_id => mandates.id)
#

# Defines the Investor
# rubocop:disable Metrics/ClassLength
class Investor < ApplicationRecord
  include AASM
  include GeneratedDocument
  include RememberStateTransitions

  strip_attributes only: :capital_account_number, collapse_spaces: true

  BELONG_TO_MANDATE = 'must belong to mandate'

  belongs_to :bank_account, autosave: true
  belongs_to :fund, inverse_of: :investors, autosave: true
  belongs_to :mandate, inverse_of: :investments, autosave: true
  has_many :investor_reports, dependent: :destroy
  has_many :fund_reports, -> { distinct }, through: :investor_reports
  has_many :documents, as: :owner, inverse_of: :owner, dependent: :destroy
  has_many :investor_cashflows, dependent: :nullify
  has_one :contact_address, through: :mandate
  has_one :legal_address, through: :mandate
  has_one :primary_contact, through: :mandate
  has_one :primary_owner, through: :mandate
  has_one :secondary_contact, through: :mandate
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

      transitions from: %i[created signed], to: :signed
    end
  end

  alias_attribute :state, :aasm_state

  validates :fund, presence: true
  validates :mandate, presence: true
  validates :amount_total, presence: true
  validate :attributes_in_signed_state
  validate :bank_account_belongs_to_mandate

  delegate(
    :contact_address,
    :contact_salutation_primary_contact,
    :contact_salutation_primary_owner,
    :contact_salutation_secondary_contact,
    :legal_address,
    :primary_contact,
    :primary_owner,
    :secondary_contact,
    to: :mandate
  )

  def amount_called
    investor_cashflows.sum(&:capital_call_total_amount)
  end

  def amount_open
    amount_total - amount_called + amount_recallable
  end

  def amount_recallable
    investor_cashflows.sum(&:distribution_recallable_amount)
  end

  def amount_total_distribution
    investor_cashflows.sum(&:distribution_total_amount)
  end

  def current_value
    # TODO: Implement actual logic
    -1
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

  def subscription_agreement_document_context
    Document::FundTemplate.fund_subscription_agreement_context(self)
  end

  def subscription_agreement_document(current_user:, regenerate: false)
    return fund_subscription_agreement if fund_subscription_agreement && !regenerate

    transaction do
      template = fund.subscription_agreement_template
      clean_up_existing_subscription_agreement_document if regenerate
      find_or_create_document(
        template: template, template_context: subscription_agreement_document_context,
        uploader: current_user, document_category: :generated_subscription_agreement_document,
        name: subscription_agreement_document_name(template)
      )
    end
  end

  private

  def clean_up_existing_subscription_agreement_document
    document = find_generated_document_by_category(:generated_quarterly_report_document)
    document&.destroy!
  end

  def subscription_agreement_document_name(template)
    extension = Docx.docx?(template.file) ? 'docx' : 'pdf'
    mandate_identifier = mandate.decorate.owner_name
    "Zeichnungsschein_#{mandate_identifier}.#{extension}"
  end

  # Validates presence of investment_date and fund_subscription_agreement if state is `signed`
  # @return [void]
  def attributes_in_signed_state
    return unless signed?

    error_message = 'must be present if investor is signed'
    errors.add(:investment_date, error_message) if investment_date.nil?
    errors.add(:fund_subscription_agreement, error_message) if fund_subscription_agreement.nil?
  end

  def bank_account_belongs_to_mandate
    errors.add(:bank_account, BELONG_TO_MANDATE) if bank_account.present? && bank_account.owner != mandate
  end

  def set_investment_date
    self.investment_date = Time.zone.now if investment_date.nil?
  end
end
# rubocop:enable Metrics/ClassLength
