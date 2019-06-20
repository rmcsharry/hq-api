# frozen_string_literal: true

# == Schema Information
#
# Table name: documents
#
#  aasm_state  :string           default("created"), not null
#  category    :string           not null
#  created_at  :datetime         not null
#  id          :uuid             not null, primary key
#  name        :string           not null
#  owner_id    :uuid
#  owner_type  :string
#  type        :string
#  updated_at  :datetime         not null
#  uploader_id :uuid             not null
#  valid_from  :date
#  valid_to    :date
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

    # Overwrite Document's Lockable concern by setting grace_perios_expired? to false for templates
    def grace_period_expired?
      false
    end

    def self.fund_capital_call_context(investor_cashflow)
      fund_distribution_context(investor_cashflow)
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/LineLength
    def self.fund_distribution_context(investor_cashflow)
      investor_cashflow = investor_cashflow.decorate
      investor = investor_cashflow.investor.decorate
      fund_cashflow = investor_cashflow.fund_cashflow.decorate
      fund = investor.fund
      bank_account = fund.bank_accounts.first
      primary_owner = investor.primary_owner.decorate
      legal_address = primary_owner.legal_address&.decorate
      primary_address = investor.contact_address&.decorate
      gender_text = primary_owner.is_a?(Contact::Person) ? primary_owner.gender_text : ''
      mandate = investor.mandate.decorate
      primary_contact = investor.primary_contact&.decorate
      secondary_contact = investor.secondary_contact&.decorate
      primary_consultant = mandate.primary_consultant&.decorate
      secondary_consultant = mandate.secondary_consultant&.decorate
      description_bottom = Quill::Delta.new(fund_cashflow.description_bottom).to_s
      description_top = Quill::Delta.new(fund_cashflow.description_top).to_s

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
          company: fund.company,
          currency: fund.currency,
          name: fund.name
        },
        fund_cashflow: {
          description_bottom: Sablon.content(:word_ml, description_bottom),
          description_top: Sablon.content(:word_ml, description_top),
          number: fund_cashflow.number,
          valuta_date: fund_cashflow.valuta_date
        },
        investor: {
          amount_total: investor.amount_total,
          confidential: mandate.humanize_confidential,
          contact_address: {
            city: primary_address.city,
            full_address: primary_address&.letter_address(investor.contact_names),
            postal_code: primary_address.postal_code,
            street_and_number: primary_address.street_and_number
          },
          formal_salutation: investor.formal_salutation,
          legal_address: {
            full_address: legal_address&.letter_address(primary_owner.name)
          },
          primary_consultant: {
            full_name: primary_consultant&.name,
            primary_email_address: primary_consultant&.primary_email,
            primary_phone: primary_consultant&.primary_phone
          },
          primary_contact: {
            full_name: primary_contact&.name,
            primary_email_address: primary_contact&.primary_email,
            primary_phone: primary_contact&.primary_phone
          },
          primary_owner: {
            formal_salutation: primary_owner.formal_salutation,
            full_name: primary_owner.name,
            gender: gender_text
          },
          secondary_consultant: {
            full_name: secondary_consultant&.name,
            primary_email_address: secondary_consultant&.primary_email,
            primary_phone: secondary_consultant&.primary_phone
          },
          secondary_contact: {
            full_name: secondary_contact&.name,
            primary_email_address: secondary_contact&.primary_email,
            primary_phone: secondary_contact&.primary_phone
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
          distribution_withholding_tax_percentage: investor_cashflow.distribution_withholding_tax_percentage,
          net_cashflow_amount: investor_cashflow.net_cashflow_amount,
          net_cashflow_percentage: investor_cashflow.net_cashflow_percentage,
          total_amount: investor_cashflow.net_cashflow_amount,
          total_percentage: investor_cashflow.net_cashflow_percentage
        }
      }
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/LineLength

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def self.fund_quarterly_report_context(investor, fund_report)
      investor = investor.decorate
      fund = investor.fund
      primary_owner = investor.primary_owner.decorate
      legal_address = primary_owner.legal_address&.decorate
      primary_address = investor.contact_address&.decorate
      current_date = Time.zone.now.strftime('%d.%m.%Y')
      description = Quill::Delta.new(fund_report.description).to_s
      gender_text = primary_owner.is_a?(Contact::Person) ? primary_owner.gender_text : ''
      mandate = investor.mandate.decorate
      primary_contact = investor.primary_contact&.decorate
      secondary_contact = investor.secondary_contact&.decorate
      primary_consultant = mandate.primary_consultant&.decorate
      secondary_consultant = mandate.secondary_consultant&.decorate

      {
        current_date: current_date,
        fund: {
          company: fund.company,
          currency: fund.currency,
          name: fund.name
        },
        fund_report: {
          description: Sablon.content(:word_ml, description)
        },
        investor: {
          amount_total: investor.amount_total,
          confidential: mandate.humanize_confidential,
          contact_address: {
            city: primary_address.city,
            full_address: primary_address&.letter_address(investor.contact_names),
            postal_code: primary_address.postal_code,
            street_and_number: primary_address.street_and_number
          },
          formal_salutation: investor.formal_salutation,
          legal_address: {
            full_address: legal_address&.letter_address(primary_owner.name)
          },
          primary_consultant: {
            full_name: primary_consultant&.name,
            primary_email_address: primary_consultant&.primary_email,
            primary_phone: primary_consultant&.primary_phone
          },
          primary_contact: {
            full_name: primary_contact&.name,
            primary_email_address: primary_contact&.primary_email,
            primary_phone: primary_contact&.primary_phone
          },
          primary_owner: {
            formal_salutation: primary_owner.formal_salutation,
            full_name: primary_owner.name,
            gender: gender_text
          },
          secondary_consultant: {
            full_name: secondary_consultant&.name,
            primary_email_address: secondary_consultant&.primary_email,
            primary_phone: secondary_consultant&.primary_phone
          },
          secondary_contact: {
            full_name: secondary_contact&.name,
            primary_email_address: secondary_contact&.primary_email,
            primary_phone: secondary_contact&.primary_phone
          }
        }
      }
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def self.fund_subscription_agreement_context(investor)
      investor = investor.decorate
      fund = investor.fund
      primary_owner = investor.primary_owner.decorate
      bank_account = investor.bank_account
      primary_contact = investor.primary_contact&.decorate
      secondary_contact = investor.secondary_contact&.decorate
      current_date = Time.zone.now.strftime('%d.%m.%Y')
      primary_owner_birth_date = primary_owner.date_of_birth ? primary_owner.date_of_birth.strftime('%d.%m.%Y') : '-'
      legal_address = primary_owner.legal_address&.decorate
      primary_fax = primary_owner.contact_details.find_by(type: 'ContactDetail::Fax', primary: true)&.value
      mandate = investor.mandate.decorate
      primary_consultant = mandate.primary_consultant&.decorate
      secondary_consultant = mandate.secondary_consultant&.decorate
      primary_address = investor.contact_address&.decorate

      {
        current_date: current_date,
        fund: {
          company: fund.company,
          name: fund.name
        },
        investor: {
          bank_account: {
            account_number: bank_account.bank_account_number,
            bic: bank_account.bic,
            iban: bank_account.iban,
            routing_number: bank_account.bank_routing_number
          },
          confidential: mandate.humanize_confidential,
          contact_address: {
            full_address: primary_address&.letter_address(investor.contact_names)
          },
          contact_phone: primary_owner.primary_phone&.value,
          formal_salutation: investor.formal_salutation,
          legal_address: {
            addition: legal_address&.addition,
            city: legal_address&.city,
            country: legal_address&.country,
            full_address: legal_address&.letter_address(primary_owner.name),
            postal_code: legal_address&.postal_code,
            state: legal_address&.state,
            street_and_number: legal_address&.street_and_number
          },
          primary_consultant: {
            full_name: primary_consultant&.name,
            primary_email_address: primary_consultant&.primary_email,
            primary_phone: primary_consultant&.primary_phone
          },
          primary_contact: {
            full_name: primary_contact&.name,
            primary_email_address: primary_contact&.primary_email,
            primary_phone: primary_contact&.primary_phone
          },
          primary_owner: {
            birth_date: primary_owner_birth_date,
            commercial_register_number: primary_owner.commercial_register_number,
            commercial_register_office: primary_owner.commercial_register_office,
            full_name: primary_owner.name,
            nationality: primary_owner.nationality,
            organization_type: primary_owner.organization_type,
            place_of_birth: primary_owner.place_of_birth,
            primary_fax: primary_fax,
            tax_numbers: primary_owner.tax_numbers
          },
          secondary_consultant: {
            full_name: secondary_consultant&.name,
            primary_email_address: secondary_consultant&.primary_email,
            primary_phone: secondary_consultant&.primary_phone
          },
          secondary_contact: {
            full_name: secondary_contact&.name,
            primary_email_address: secondary_contact&.primary_email,
            primary_phone: secondary_contact&.primary_phone
          }
        }
      }
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    private

    def replace_exisiting_fund_template
      Document::FundTemplate.where(owner: owner, category: category).find_each(&:destroy!)
    end
  end
  # rubocop:enable Metrics/ClassLength
end
