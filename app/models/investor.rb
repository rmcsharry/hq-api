# frozen_string_literal: true

# == Schema Information
#
# Table name: investors
#
#  id                                   :uuid             not null, primary key
#  fund_id                              :uuid
#  mandate_id                           :uuid
#  legal_address_id                     :uuid
#  contact_address_id                   :uuid
#  bank_account_id                      :uuid
#  primary_owner_id                     :uuid
#  aasm_state                           :string           not null
#  investment_date                      :datetime
#  amount_total                         :decimal(20, 2)
#  created_at                           :datetime         not null
#  updated_at                           :datetime         not null
#  primary_contact_id                   :uuid
#  secondary_contact_id                 :uuid
#  capital_account_number               :string
#  contact_salutation_primary_owner     :boolean
#  contact_salutation_primary_contact   :boolean
#  contact_salutation_secondary_contact :boolean
#
# Indexes
#
#  index_investors_on_fund_id               (fund_id)
#  index_investors_on_mandate_id            (mandate_id)
#  index_investors_on_primary_contact_id    (primary_contact_id)
#  index_investors_on_secondary_contact_id  (secondary_contact_id)
#
# Foreign Keys
#
#  fk_rails_...  (bank_account_id => bank_accounts.id)
#  fk_rails_...  (contact_address_id => addresses.id)
#  fk_rails_...  (fund_id => funds.id)
#  fk_rails_...  (legal_address_id => addresses.id)
#  fk_rails_...  (mandate_id => mandates.id)
#  fk_rails_...  (primary_contact_id => contacts.id)
#  fk_rails_...  (primary_owner_id => contacts.id)
#  fk_rails_...  (secondary_contact_id => contacts.id)
#

# Defines the Investor
# rubocop:disable Metrics/ClassLength
class Investor < ApplicationRecord
  include AASM
  include GeneratedDocument

  BELONG_TO_CONTACTS = 'must belong to contacts (primary owner or primary/secondary contact'
  BELONG_TO_MANDATE = 'must belong to mandate'
  BELONG_TO_PRIMARY_OWNER = 'must belong to primary owner'

  belongs_to :bank_account, autosave: true
  belongs_to :contact_address, class_name: 'Address', autosave: true
  belongs_to :fund, inverse_of: :investors, autosave: true
  belongs_to :legal_address, class_name: 'Address', autosave: true
  belongs_to :mandate, inverse_of: :investments, autosave: true
  belongs_to :primary_owner, class_name: 'Contact', autosave: true
  belongs_to :primary_contact, class_name: 'Contact', optional: true, inverse_of: :primary_contact_investors
  belongs_to(
    :secondary_contact, class_name: 'Contact', optional: true, inverse_of: :secondary_contact_investors
  )
  has_many :investor_reports, dependent: :destroy
  has_many :fund_reports, -> { distinct }, through: :investor_reports
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

      transitions from: %i[created signed], to: :signed
    end
  end

  alias_attribute :state, :aasm_state

  validates :fund, presence: true
  validates :mandate, presence: true
  validates :amount_total, presence: true
  validate :attributes_in_signed_state
  validate :bank_account_belongs_to_mandate
  validate :contact_address_belongs_to_contacts
  validate :legal_address_belongs_to_primary_owner
  validate :primary_contact_belongs_to_mandate
  validate :primary_owner_belongs_to_mandate
  validate :secondary_contact_belongs_to_mandate

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

  def subscription_agreement_document(current_user)
    return fund_subscription_agreement if fund_subscription_agreement

    template = fund.subscription_agreement_template
    find_or_create_document(
      document_category: :generated_subscription_agreement_document,
      name: subscription_agreement_document_name(template),
      template: template,
      template_context: subscription_agreement_document_context,
      uploader: current_user
    )
  end

  def regenerated_subscription_agreement_document(current_user)
    transaction do
      template = fund.subscription_agreement_template
      document = find_generated_document_by_category(:generated_subscription_agreement_document)
      document&.destroy!
      apply_template_and_persist_document(
        template: template, template_context: subscription_agreement_document_context,
        uploader: current_user, document_category: :generated_subscription_agreement_document,
        name: subscription_agreement_document_name(template)
      )
    end
  end

  private

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

  def primary_owner_belongs_to_mandate
    return if primary_owner.blank? || mandate.owners.map(&:contact).include?(primary_owner)

    errors.add(:primary_owner, BELONG_TO_MANDATE)
  end

  def primary_contact_belongs_to_mandate
    return if primary_contact.blank? || valid_contacts.include?(primary_contact)

    errors.add(:primary_contact, BELONG_TO_MANDATE)
  end

  def secondary_contact_belongs_to_mandate
    return if secondary_contact.blank? || valid_contacts.include?(secondary_contact)

    errors.add(:secondary_contact, BELONG_TO_MANDATE)
  end

  def contact_address_belongs_to_contacts
    return if contact_address.blank? ||
              [primary_owner, primary_contact, secondary_contact].compact.include?(contact_address.owner)

    errors.add(:contact_address, BELONG_TO_CONTACTS)
  end

  def legal_address_belongs_to_primary_owner
    return if legal_address.blank? || legal_address.owner == primary_owner

    errors.add(:legal_address, BELONG_TO_PRIMARY_OWNER)
  end

  def set_investment_date
    self.investment_date = Time.zone.now if investment_date.nil?
  end

  def valid_contacts
    mandate.mandate_members.map(&:contact) + [
      mandate.primary_consultant, mandate.secondary_consultant, mandate.assistant, mandate.bookkeeper
    ]
  end
end
# rubocop:enable Metrics/ClassLength
