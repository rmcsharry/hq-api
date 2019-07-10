# frozen_string_literal: true

# == Schema Information
#
# Table name: contacts
#
#  comment                       :text
#  commercial_register_number    :string
#  commercial_register_office    :string
#  created_at                    :datetime         not null
#  data_integrity_missing_fields :string           default([]), is an Array
#  data_integrity_score          :decimal(5, 4)    default(0.0)
#  date_of_birth                 :date
#  date_of_death                 :date
#  first_name                    :string
#  gender                        :string
#  id                            :uuid             not null, primary key
#  import_id                     :integer
#  last_name                     :string
#  legal_address_id              :uuid
#  maiden_name                   :string
#  nationality                   :string
#  nobility_title                :string
#  organization_category         :string
#  organization_industry         :string
#  organization_name             :string
#  organization_type             :string
#  place_of_birth                :string
#  primary_contact_address_id    :uuid
#  professional_title            :string
#  type                          :string
#  updated_at                    :datetime         not null
#
# Indexes
#
#  index_contacts_on_data_integrity_score        (data_integrity_score)
#  index_contacts_on_legal_address_id            (legal_address_id)
#  index_contacts_on_primary_contact_address_id  (primary_contact_address_id)
#
# Foreign Keys
#
#  fk_rails_...  (legal_address_id => addresses.id)
#  fk_rails_...  (primary_contact_address_id => addresses.id)
#

# Defines the Contact model
# rubocop:disable Metrics/ClassLength
class Contact < ApplicationRecord
  include ExportableAttributes
  include Scoreable
  extend Enumerize
  strip_attributes only: %i[
    commercial_register_number commercial_register_office first_name last_name maiden_name nationality
    organization_category organization_industry organization_name organization_type place_of_birth
  ], collapse_spaces: true

  belongs_to :legal_address, class_name: 'Address', optional: true, inverse_of: :owner, autosave: true
  belongs_to :primary_contact_address, class_name: 'Address', optional: true, inverse_of: :owner, autosave: true
  has_many :addresses, as: :owner, inverse_of: :owner, dependent: :destroy
  has_many :child_versions, class_name: 'Version', as: :parent_item # rubocop:disable Rails/HasManyOrHasOneDependent
  has_many :contact_details, dependent: :destroy
  has_many :documents, as: :owner, inverse_of: :owner, dependent: :nullify
  has_many :mandate_members, dependent: :destroy
  has_many :mandates, through: :mandate_members
  has_many :investors, foreign_key: :primary_owner_id, inverse_of: :primary_owner, dependent: :nullify
  has_many :reminders, class_name: 'Task', as: :subject, inverse_of: :subject, dependent: :destroy
  has_many :task_links, class_name: 'Task', as: :linked_object, inverse_of: :linked_object, dependent: :destroy
  has_many :active_contact_relationships,
           class_name: 'ContactRelationship',
           dependent: :destroy,
           foreign_key: :source_contact_id,
           inverse_of: :source_contact
  has_many :passive_contact_relationships,
           class_name: 'ContactRelationship',
           dependent: :destroy,
           foreign_key: :target_contact_id,
           inverse_of: :target_contact
  has_many(
    :primary_contact_investors, class_name: 'Investor', foreign_key: :primary_contact_id,
                                inverse_of: :primary_contact, dependent: :nullify
  )
  has_many(
    :secondary_contact_investors, class_name: 'Investor', foreign_key: :secondary_contact_id,
                                  inverse_of: :secondary_contact, dependent: :nullify
  )
  has_many :list_items, as: :listable, class_name: 'List::Item', dependent: :destroy, inverse_of: :listable
  has_many :lists, through: :list_items
  has_one :compliance_detail, dependent: :destroy, autosave: true
  has_one :tax_detail, dependent: :destroy, autosave: true
  has_one :user, dependent: :nullify
  has_one :primary_email,
          -> { where(primary: true) },
          class_name: 'ContactDetail::Email',
          inverse_of: :contact
  has_one :primary_phone,
          -> { where(primary: true) },
          class_name: 'ContactDetail::Phone',
          inverse_of: :contact
  has_and_belongs_to_many :activities, -> { distinct }

  has_paper_trail(
    meta: {
      parent_item_id: :id,
      parent_item_type: 'Contact'
    },
    skip: SKIPPED_ATTRIBUTES
  )

  scope :with_name, lambda {
    from(
      "(SELECT COALESCE(first_name || ' ' || last_name, organization_name) AS name, " \
      "COALESCE(last_name || ', ' || first_name, organization_name) AS name_list, " \
      'contacts.* FROM contacts) contacts'
    )
  }

  scope :associated_to_mandate_with_id, lambda { |mandate_id|
    joins(
      <<-SQL.squish
        LEFT JOIN mandate_members mm
        ON contacts.id = mm.contact_id
      SQL
    )
      .where('mm.mandate_id = ?', mandate_id)
  }

  before_create :add_tax_detail
  before_validation :assign_primary_contact_address, on: :create

  validates_associated :legal_address, :primary_contact_address, :compliance_detail, :tax_detail
  validates :data_integrity_score, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }

  alias_attribute :contact_type, :type

  # Returns boolean to define whether the contact is an organization or not
  # @return [Boolean] generally false, overwritten in subclass
  def organization?
    false
  end

  def legal_address_text
    legal_address&.to_s
  end

  def primary_contact_address_text
    primary_contact_address&.to_s
  end

  def mandate_member?
    mandate_members.length.positive?
  end

  def mandate_owner?
    mandate_members.any? { |member| member.member_type == :owner }
  end

  alias is_mandate_member mandate_member?
  alias is_mandate_owner mandate_owner?

  def task_assignees
    associated_mandate_ids = Mandate
                             .joins('LEFT JOIN mandate_members ON mandates.id = mandate_members.mandate_id')
                             .where('mandate_members.contact_id = ?', id)
                             .pluck(:id)

    assigned_contact_ids = MandateMember
                           .where(member_type: %i[assistant primary_consultant secondary_consultant])
                           .where(mandate_id: associated_mandate_ids)
                           .pluck(:contact_id)

    User.where(contact_id: assigned_contact_ids)
  end

  private

  def add_tax_detail
    build_tax_detail unless tax_detail
  end

  def assign_primary_contact_address
    self.primary_contact_address = legal_address unless primary_contact_address
  end
end
# rubocop:enable Metrics/ClassLength
