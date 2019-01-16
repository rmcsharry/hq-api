# frozen_string_literal: true

# == Schema Information
#
# Table name: documents
#
#  id          :uuid             not null, primary key
#  name        :string           not null
#  category    :string           not null
#  valid_from  :date
#  valid_to    :date
#  uploader_id :uuid             not null
#  owner_type  :string
#  owner_id    :uuid
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  type        :string
#
# Indexes
#
#  index_documents_on_owner_type_and_owner_id  (owner_type,owner_id)
#  index_documents_on_uploader_id              (uploader_id)
#
# Foreign Keys
#
#  fk_rails_...  (uploader_id => users.id)
#

class Document
  # Defines the Document model for fund template documents
  # rubocop:disable Metrics/ClassLength
  class FundTemplate < Document
    def self.policy_class
      DocumentPolicy
    end

    CATEGORIES = %i[
      fund_capital_call_template
      fund_distribution_template
      fund_quarterly_report_template
      fund_subscription_agreement_template
    ].freeze

    enumerize :category, in: CATEGORIES, scope: true

    validates(
      :category,
      uniqueness: { scope: %i[owner],
                    message: 'should occur only once per owner', case_sensitive: false }
    )

    before_validation :replace_exisiting_fund_template, on: :create

    # Overwrite Document's Lockable concern by setting readonly? to false for templates
    def readonly?
      false
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def self.fund_capital_call_context(investor_cashflow:)
      investor_cashflow = investor_cashflow.decorate
      investor = investor_cashflow.investor.decorate
      fund_cashflow = investor_cashflow.fund_cashflow.decorate
      fund = investor.fund
      bank_account = fund.bank_accounts.first
      primary_owner = investor.primary_owner.decorate
      primary_address = investor.contact_address
      gender_text = primary_owner.is_a?(Contact::Person) ? primary_owner.gender_text : ''

      current_date = Time.zone.now.strftime('%d.%m.%Y')

      {
        current_date: current_date,
        fund: {
          bank_account: {
            account_number: bank_account&.bank_account_number,
            bic: bank_account&.bic,
            iban: bank_account&.iban,
            owner_name: bank_account&.owner_name,
            routing_number: bank_account&.bank_routing_number
          },
          currency: fund.currency,
          name: fund.name
        },
        fund_cashflow: {
          number: fund_cashflow.number,
          valuta_date: fund_cashflow.valuta_date
        },
        investor: {
          amount_total: investor.amount_total,
          contact_address: {
            city: primary_address.city,
            postal_code: primary_address.postal_code,
            street_and_number: primary_address.street_and_number
          },
          primary_owner: {
            formal_salutation: primary_owner.formal_salutation,
            full_name: primary_owner.name,
            gender: gender_text
          }
        },
        investor_cashflow: {
          capital_call_total_amount: investor_cashflow.capital_call_total_amount,
          capital_call_total_percentage: investor_cashflow.capital_call_total_percentage
        }
      }
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/LineLength
    def self.fund_distribution_context(investor_cashflow:)
      investor_cashflow = investor_cashflow.decorate
      investor = investor_cashflow.investor.decorate
      fund_cashflow = investor_cashflow.fund_cashflow.decorate
      fund = investor.fund
      primary_owner = investor.primary_owner.decorate
      primary_address = investor.contact_address
      gender_text = primary_owner.is_a?(Contact::Person) ? primary_owner.gender_text : ''

      current_date = Time.zone.now.strftime('%d.%m.%Y')

      {
        current_date: current_date,
        fund: {
          currency: fund.currency,
          name: fund.name
        },
        fund_cashflow: {
          number: fund_cashflow.number,
          valuta_date: fund_cashflow.valuta_date
        },
        investor: {
          amount_total: investor.amount_total,
          contact_address: {
            city: primary_address.city,
            postal_code: primary_address.postal_code,
            street_and_number: primary_address.street_and_number
          },
          primary_owner: {
            formal_salutation: primary_owner.formal_salutation,
            full_name: primary_owner.name,
            gender: gender_text
          }
        },
        investor_cashflow: {
          capital_call_management_fees_amount: investor_cashflow.capital_call_management_fees_amount,
          capital_call_management_fees_percentage: investor_cashflow.capital_call_management_fees_percentage,
          capital_call_compensatory_interest_amount: investor_cashflow.capital_call_compensatory_interest_amount,
          capital_call_compensatory_interest_percentage: investor_cashflow.capital_call_compensatory_interest_percentage,
          capital_call_gross_amount: investor_cashflow.capital_call_gross_amount,
          capital_call_gross_percentage: investor_cashflow.capital_call_gross_percentage,
          capital_call_total_amount: investor_cashflow.capital_call_total_amount,
          capital_call_total_percentage: investor_cashflow.capital_call_total_percentage,
          distribution_compensatory_interest_amount: investor_cashflow.distribution_compensatory_interest_amount,
          distribution_compensatory_interest_percentage: investor_cashflow.distribution_compensatory_interest_percentage,
          distribution_dividends_amount: investor_cashflow.distribution_dividends_amount,
          distribution_dividends_percentage: investor_cashflow.distribution_dividends_percentage,
          distribution_interest_amount: investor_cashflow.distribution_interest_amount,
          distribution_interest_percentage: investor_cashflow.distribution_interest_percentage,
          distribution_misc_profits_amount: investor_cashflow.distribution_misc_profits_amount,
          distribution_misc_profits_percentage: investor_cashflow.distribution_misc_profits_percentage,
          distribution_participation_profits_amount: investor_cashflow.distribution_participation_profits_amount,
          distribution_participation_profits_percentage: investor_cashflow.distribution_participation_profits_percentage,
          distribution_recallable_amount: investor_cashflow.distribution_recallable_amount,
          distribution_recallable_percentage: investor_cashflow.distribution_recallable_percentage,
          distribution_repatriation_amount: investor_cashflow.distribution_repatriation_amount,
          distribution_repatriation_percentage: investor_cashflow.distribution_repatriation_percentage,
          distribution_structure_costs_amount: investor_cashflow.distribution_structure_costs_amount,
          distribution_structure_costs_percentage: investor_cashflow.distribution_structure_costs_percentage,
          distribution_total_amount: investor_cashflow.distribution_total_amount,
          distribution_total_percentage: investor_cashflow.distribution_total_percentage,
          distribution_withholding_tax_amount: investor_cashflow.distribution_withholding_tax_amount,
          distribution_withholding_tax_percentage: investor_cashflow.distribution_withholding_tax_percentage
        }
      }
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/LineLength

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def self.fund_quarterly_report_context(investor:, fund_report:)
      investor = investor.decorate
      fund = investor.fund
      primary_owner = investor.primary_owner.decorate
      primary_address = investor.contact_address
      current_date = Time.zone.now.strftime('%d.%m.%Y')
      description = Quill::Delta.new(fund_report.description).to_s
      gender_text = primary_owner.is_a?(Contact::Person) ? primary_owner.gender_text : ''

      {
        current_date: current_date,
        fund: {
          currency: fund.currency,
          name: fund.name
        },
        fund_report: {
          description: description
        },
        investor: {
          amount_total: investor.amount_total,
          contact_address: {
            city: primary_address.city,
            postal_code: primary_address.postal_code,
            street_and_number: primary_address.street_and_number
          },
          primary_owner: {
            formal_salutation: primary_owner.formal_salutation,
            full_name: primary_owner.name,
            gender: gender_text
          }
        }
      }
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    # rubocop:disable Metrics/MethodLength
    def self.fund_subscription_agreement_context(investor:)
      fund = investor.fund
      primary_owner = investor.primary_owner.decorate
      current_date = Time.zone.now.strftime('%d.%m.%Y')

      {
        current_date: current_date,
        fund: {
          name: fund.name
        },
        investor: {
          primary_owner: {
            full_name: primary_owner.name
          }
        }
      }
    end
    # rubocop:enable Metrics/MethodLength

    private

    def replace_exisiting_fund_template
      Document::FundTemplate.where(owner: owner, category: category).find_each(&:destroy!)
    end
  end
  # rubocop:enable Metrics/ClassLength
end
