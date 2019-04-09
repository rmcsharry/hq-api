# frozen_string_literal: true

# == Schema Information
#
# Table name: contacts
#
#  id                         :uuid             not null, primary key
#  first_name                 :string
#  last_name                  :string
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  type                       :string
#  comment                    :text
#  gender                     :string
#  nobility_title             :string
#  professional_title         :string
#  maiden_name                :string
#  date_of_birth              :date
#  date_of_death              :date
#  nationality                :string
#  organization_name          :string
#  organization_type          :string
#  organization_category      :string
#  organization_industry      :string
#  commercial_register_number :string
#  commercial_register_office :string
#  legal_address_id           :uuid
#  primary_contact_address_id :uuid
#  import_id                  :integer
#  place_of_birth             :string
#
# Indexes
#
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
  extend Enumerize

  belongs_to :legal_address, class_name: 'Address', optional: true, inverse_of: :owner, autosave: true
  belongs_to :primary_contact_address, class_name: 'Address', optional: true, inverse_of: :owner, autosave: true
  has_many :addresses, as: :owner, inverse_of: :owner, dependent: :destroy
  has_many :child_versions, class_name: 'Version', as: :parent_item # rubocop:disable Rails/HasManyOrHasOneDependent
  has_many :contact_details, dependent: :destroy
  has_many :documents, as: :owner, inverse_of: :owner, dependent: :nullify
  has_many :mandate_members, dependent: :destroy
  has_many :mandates, through: :mandate_members
  has_many :organization_members, dependent: :destroy, inverse_of: :contact
  has_many :organizations, through: :organization_members
  has_many :investors, foreign_key: :primary_owner_id, inverse_of: :primary_owner, dependent: :nullify
  has_many :reminders, class_name: 'Task', as: :subject, inverse_of: :subject, dependent: :destroy
  has_many :task_links, class_name: 'Task', as: :linked_object, inverse_of: :linked_object, dependent: :destroy
  has_many(
    :active_person_relationships, class_name: 'InterPersonRelationship', dependent: :destroy,
                                  inverse_of: :source_person, foreign_key: :source_person_id
  )
  has_many(
    :passive_person_relationships, class_name: 'InterPersonRelationship', dependent: :destroy,
                                   inverse_of: :target_person, foreign_key: :target_person_id
  )
  has_many :actively_related_persons, class_name: 'Contact::Person', through: :active_person_relationships
  has_many :passively_related_persons, class_name: 'Contact::Person', through: :passive_person_relationships
  has_many(
    :primary_consultant_mandates, class_name: 'Mandate', foreign_key: :primary_consultant_id,
                                  inverse_of: :primary_consultant, dependent: :nullify
  )
  has_many(
    :secondary_consultant_mandates, class_name: 'Mandate', foreign_key: :secondary_consultant_id,
                                    inverse_of: :secondary_consultant, dependent: :nullify
  )
  has_many(
    :primary_contact_investors, class_name: 'Investor', foreign_key: :primary_contact_id,
                                inverse_of: :primary_contact, dependent: :nullify
  )
  has_many(
    :secondary_contact_investors, class_name: 'Investor', foreign_key: :secondary_contact_id,
                                  inverse_of: :secondary_contact, dependent: :nullify
  )
  has_many(
    :assistant_mandates, class_name: 'Mandate', foreign_key: :assistant_id, inverse_of: :assistant, dependent: :nullify
  )
  has_many(
    :bookkeeper_mandates, class_name: 'Mandate', foreign_key: :bookkeeper_id, inverse_of: :bookkeeper,
                          dependent: :nullify
  )
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
        LEFT JOIN mandates m
        ON contacts.id = m.primary_consultant_id
        OR contacts.id = m.secondary_consultant_id
        OR contacts.id = m.assistant_id
        OR contacts.id = m.bookkeeper_id
      SQL
    )
      .joins(
        <<-SQL.squish
          LEFT JOIN mandate_members mm
          ON contacts.id = mm.contact_id
        SQL
      )
      .where('mm.mandate_id = ? OR m.id = ?', mandate_id, mandate_id)
  }

  before_create :add_tax_detail
  before_validation :assign_primary_contact_address, on: :create

  validates_associated :legal_address, :primary_contact_address, :compliance_detail, :tax_detail

  alias_attribute :contact_type, :type

  # Returns boolean to define whether the contact is an organization or not
  # @return [Boolean] generaly false, overwritte in subclass
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
    assigned_contact_ids = Mandate
                           .joins('LEFT JOIN mandate_members mm ON mandates.id = mm.mandate_id')
                           .where('mm.contact_id = ?', id)
                           .pluck(:assistant_id, :primary_consultant_id, :secondary_consultant_id)

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
