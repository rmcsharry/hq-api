# frozen_string_literal: true

# == Schema Information
#
# Table name: investor_cashflows
#
#  aasm_state                                :string
#  capital_call_compensatory_interest_amount :decimal(20, 10)  default(0.0), not null
#  capital_call_gross_amount                 :decimal(20, 10)  default(0.0), not null
#  capital_call_management_fees_amount       :decimal(20, 10)  default(0.0), not null
#  created_at                                :datetime         not null
#  distribution_compensatory_interest_amount :decimal(20, 10)  default(0.0), not null
#  distribution_dividends_amount             :decimal(20, 10)  default(0.0), not null
#  distribution_interest_amount              :decimal(20, 10)  default(0.0), not null
#  distribution_misc_profits_amount          :decimal(20, 10)  default(0.0), not null
#  distribution_participation_profits_amount :decimal(20, 10)  default(0.0), not null
#  distribution_recallable_amount            :decimal(20, 10)  default(0.0), not null
#  distribution_repatriation_amount          :decimal(20, 10)  default(0.0), not null
#  distribution_structure_costs_amount       :decimal(20, 10)  default(0.0), not null
#  distribution_withholding_tax_amount       :decimal(20, 10)  default(0.0), not null
#  fund_cashflow_id                          :uuid
#  id                                        :uuid             not null, primary key
#  investor_id                               :uuid
#  updated_at                                :datetime         not null
#
# Indexes
#
#  index_investor_cashflows_on_fund_cashflow_id  (fund_cashflow_id)
#  index_investor_cashflows_on_investor_id       (investor_id)
#
# Foreign Keys
#
#  fk_rails_...  (fund_cashflow_id => fund_cashflows.id)
#  fk_rails_...  (investor_id => investors.id)
#

# Defines the InvestorCashflow
class InvestorCashflow < ApplicationRecord
  include AASM
  include GeneratedDocument

  belongs_to :fund_cashflow, inverse_of: :investor_cashflows, autosave: true, optional: false
  belongs_to :investor, inverse_of: :investor_cashflows, autosave: true, optional: false
  has_many :documents, as: :owner, inverse_of: :owner, dependent: :destroy

  has_paper_trail(
    meta: {
      parent_item_id: proc { |investor_cashflow| investor_cashflow.fund_cashflow.fund_id },
      parent_item_type: 'Fund'
    },
    skip: SKIPPED_ATTRIBUTES
  )

  aasm do
    state :open, initial: true
    state :finished

    event :finish do
      transitions from: :open, to: :finished
    end
  end

  alias_attribute :state, :aasm_state

  validate :investor_belongs_to_same_fund_as_fund_cashflow
  validate :investor_has_signed

  def net_cashflow_amount
    distribution_total_amount - capital_call_total_amount
  end

  # rubocop:disable Metrics/AbcSize
  def distribution_total_amount
    distribution_repatriation_amount +
      distribution_participation_profits_amount +
      distribution_dividends_amount +
      distribution_interest_amount +
      distribution_misc_profits_amount +
      distribution_structure_costs_amount +
      distribution_withholding_tax_amount +
      distribution_recallable_amount +
      distribution_compensatory_interest_amount
  end
  # rubocop:enable Metrics/AbcSize

  def capital_call_total_amount
    capital_call_gross_amount +
      capital_call_compensatory_interest_amount +
      capital_call_management_fees_amount
  end

  def investor_called_amount
    previous_investor_cashflows.sum(&:capital_call_total_amount)
  end

  def investor_called_percentage
    investor.amount_total.zero? ? 1.0 : investor_called_amount / investor.amount_total
  end

  def investor_open_amount
    investor.amount_total - investor_called_amount + investor_recallable_amount
  end

  def investor_open_percentage
    investor.amount_total.zero? ? 0.0 : investor_open_amount / investor.amount_total
  end

  def investor_recallable_amount
    previous_investor_cashflows.sum(&:distribution_recallable_amount)
  end

  def cashflow_document_context
    if fund_cashflow.fund_cashflow_type == :capital_call
      Document::FundTemplate.fund_capital_call_context(self)
    else
      Document::FundTemplate.fund_distribution_context(self)
    end
  end

  def cashflow_document(current_user)
    template = investor.fund.cashflow_template(fund_cashflow)
    find_or_create_document(
      document_category: :generated_cashflow_document,
      name: cashflow_document_name(template),
      template: template,
      template_context: cashflow_document_context,
      uploader: current_user
    )
  end

  private

  def cashflow_document_name(template)
    return if template.nil?

    extension = Docx.docx?(template.file) ? 'docx' : 'pdf'
    "#{cashflow_document_file_name}.#{extension}"
  end

  def cashflow_document_file_name
    mandate_identifier = investor.mandate.decorate.owner_name
    cashflow_type = fund_cashflow.fund_cashflow_type == :capital_call ? 'Kapitalabruf' : 'Ausschuettung'
    date = fund_cashflow.valuta_date.strftime('%y%m%d')
    # A randomized string at the end is needed to prevent two casfhlow documents in the same ZIP to have the same name
    # This can happen if the same mandate has multiple investors on the same fund.
    "#{date}_Anschreiben_#{cashflow_type}_#{fund_cashflow.fund.name}_#{mandate_identifier}_#{id[0..7]}"
  end

  # Validates that the investor belongs to the same fund as the fund cashflow
  # @return [void]
  def investor_belongs_to_same_fund_as_fund_cashflow
    return if investor&.fund == fund_cashflow&.fund

    errors.add(:investor, 'does not belong to the same fund as the fund cashflow')
  end

  # Validates that the investor has signed already
  # @return [void]
  def investor_has_signed
    return if investor&.signed?

    errors.add(:investor, 'has to have signed')
  end

  def previous_investor_cashflows
    fund_cashflow.fund.fund_cashflows.where('number <= ?', fund_cashflow.number)
    InvestorCashflow.joins(:fund_cashflow)
                    .where(investor: investor)
                    .where(fund_cashflows: { fund: fund_cashflow.fund })
                    .where('fund_cashflows.number <= ?', fund_cashflow.number)
  end
end
