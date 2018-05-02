# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::UserResource, type: :resource do
  let(:user) { create(:user) }
  subject { described_class.new(user, {}) }

  it { is_expected.to have_attribute :comment }
  it { is_expected.to have_attribute :confirmed_at }
  it { is_expected.to have_attribute :created_at }
  it { is_expected.to have_attribute :current_sign_in_at }
  it { is_expected.to have_attribute :email }
  it { is_expected.to have_attribute :sign_in_count }
  it { is_expected.to have_attribute :updated_at }
  it { is_expected.to have_attribute :user_group_count }

  it { is_expected.to have_many(:user_groups) }
  it { is_expected.to have_one(:contact) }

  it { is_expected.to filter(:"contact.name") }
  it { is_expected.to filter(:confirmed_at_max) }
  it { is_expected.to filter(:confirmed_at_min) }
  it { is_expected.to filter(:created_at_max) }
  it { is_expected.to filter(:created_at_min) }
  it { is_expected.to filter(:current_sign_in_at_max) }
  it { is_expected.to filter(:current_sign_in_at_min) }
  it { is_expected.to filter(:email) }
  it { is_expected.to filter(:sign_in_count) }
  it { is_expected.to filter(:updated_at_max) }
  it { is_expected.to filter(:updated_at_min) }
  it { is_expected.to filter(:user_group_id) }

  it { is_expected.to have_sortable_field(:"contact.name") }
end
