RSpec.describe V1::MandateGroupResource, type: :resource do
  let(:mandate_group) { build(:mandate_group) }
  subject { described_class.new(mandate_group, {}) }

  it { is_expected.to have_attribute :name }
  it { is_expected.to have_attribute :group_type }

  it { is_expected.to have_many(:mandates) }
  it { is_expected.to have_many(:user_groups) }
end
