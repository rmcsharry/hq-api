# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::InterPersonRelationshipResource, type: :resource do
  let(:inter_person_relationship) { create(:inter_person_relationship) }
  subject { described_class.new(inter_person_relationship, {}) }

  it { is_expected.to have_attribute :role }

  it { is_expected.to have_one(:source_person) }
  it { is_expected.to have_one(:target_person) }

  it { is_expected.to filter(:person_id) }
end
