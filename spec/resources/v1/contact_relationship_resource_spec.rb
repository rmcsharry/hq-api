# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::ContactRelationshipResource, type: :resource do
  let(:contact_relationship) { create(:person_person_relationship) }
  subject { described_class.new(contact_relationship, {}) }

  it { is_expected.to have_attribute :comment }
  it { is_expected.to have_attribute :role }

  it { is_expected.to have_one(:source_contact) }
  it { is_expected.to have_one(:target_contact) }

  it { is_expected.to filter(:contact_id) }
  it { is_expected.to filter(:'source_contact.type') }
  it { is_expected.to filter(:'target_contact.type') }
  it { is_expected.to filter(:indirectly_associating_mandates_to_contact_with_id) }

  it { is_expected.to have_sortable_field(:target_contact) }
end
