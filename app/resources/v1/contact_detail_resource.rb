# frozen_string_literal: true

module V1
  # Defines the Contact Detail resource for the API
  class ContactDetailResource < BaseResource
    model_hint model: ContactDetail::Email, resource: :contact_detail
    model_hint model: ContactDetail::Fax, resource: :contact_detail
    model_hint model: ContactDetail::Phone, resource: :contact_detail
    model_hint model: ContactDetail::Website, resource: :contact_detail

    attributes(
      :category,
      :contact_detail_type,
      :primary,
      :value
    )

    has_one :contact

    filters(
      :contact_id,
      :contact_detail_type
    )
  end
end
