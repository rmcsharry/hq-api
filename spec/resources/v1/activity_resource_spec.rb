RSpec.describe V1::ActivityResource, type: :resource do
  let(:activity) { build(:activity) }
  subject { described_class.new(activity, {}) }

  it { is_expected.to have_attribute :started_at }
  it { is_expected.to have_attribute :ended_at }
  it { is_expected.to have_attribute :title }
  it { is_expected.to have_attribute :description }

  it { is_expected.to have_many(:mandates) }
  it { is_expected.to have_many(:contacts) }
  it { is_expected.to have_many(:documents) }
end
