RSpec.describe V1::ContactDetailResource, type: :resource do
  let(:phone) { build(:phone) }
  subject { described_class.new(phone, {}) }

  it { is_expected.to have_attribute :category }
  it { is_expected.to have_attribute :value }
  it { is_expected.to have_attribute :primary }

  it { is_expected.to have_one(:contact) }
end
