RSpec.describe V1::MandateResource, type: :resource do
  let(:mandate) { build(:mandate) }
  subject { described_class.new(mandate, {}) }

  it { is_expected.to have_attribute :state }
  it { is_expected.to have_attribute :category }
  it { is_expected.to have_attribute :comment }
  it { is_expected.to have_attribute :valid_from }
  it { is_expected.to have_attribute :valid_to }
  it { is_expected.to have_attribute :datev_creditor_id }
  it { is_expected.to have_attribute :datev_debitor_id }
  it { is_expected.to have_attribute :psplus_id }

  it { is_expected.to have_many(:mandate_members) }
  it { is_expected.to have_many(:mandate_groups) }
  it { is_expected.to have_many(:documents) }
  it { is_expected.to have_one(:primary_consultant).with_class_name('Contact') }
  it { is_expected.to have_one(:secondary_consultant).with_class_name('Contact') }
  it { is_expected.to have_one(:assistant).with_class_name('Contact') }
  it { is_expected.to have_one(:bookkeeper).with_class_name('Contact') }
end
