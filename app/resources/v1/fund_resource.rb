# frozen_string_literal: true

module V1
  # Defines the Fund resource for the API
  class FundResource < BaseResource
    attributes(
      :asset_class,
      :comment,
      :commercial_register_number,
      :commercial_register_office,
      :currency,
      :documents,
      :dpi,
      :duration,
      :duration_extension,
      :holdings_last_update_at,
      :irr,
      :name,
      :psplus_asset_id,
      :region,
      :state,
      :strategy,
      :total_called_amount,
      :total_distributions_amount,
      :total_open_amount,
      :total_signed_amount,
      :tvpi,
      :updated_at
    )

    has_many :addresses
    has_many :bank_accounts
    has_many :documents
    has_many :versions, relation_name: 'child_versions', class_name: 'Version'
    has_one :capital_management_company, class_name: 'Contact'
    has_one :legal_address, class_name: 'Address'
    has_one :primary_contact_address, class_name: 'Address'

    def documents=(params)
      params.each do |param|
        document = build_document(params: param)
        @model.documents << document
        document.file.attach(param[:file])
      end
    end

    filters(
      :asset_class,
      :currency,
      :owner_id,
      :region,
      :state,
      :strategy
    )

    filter :name, apply: lambda { |records, value, _options|
      records.where('funds.name ILIKE ?', "%#{value[0]}%")
    }

    filter :capital_management_company, apply: lambda { |records, value, _options|
      records.joins(:capital_management_company).where('contacts.organization_name ILIKE ?', "%#{value[0]}%")
    }

    filter :commercial_register_number, apply: lambda { |records, value, _options|
      records.where('funds.commercial_register_number ILIKE ?', "%#{value[0]}%")
    }

    filter :commercial_register_office, apply: lambda { |records, value, _options|
      records.where('funds.commercial_register_office ILIKE ?', "%#{value[0]}%")
    }

    filter :psplus_asset_id, apply: lambda { |records, value, _options|
      records.where('funds.psplus_asset_id ILIKE ?', "%#{value[0]}%")
    }

    private

    def build_document(params:)
      params[:documentType].constantize.new(
        category: params[:category],
        name: params[:name],
        owner: @model,
        uploader: context[:current_user],
        valid_from: params[:validFrom],
        valid_to: params[:validTo]
      )
    end
  end
end
