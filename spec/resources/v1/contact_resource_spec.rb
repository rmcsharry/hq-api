RSpec.describe V1::ContactResource, type: :resource do
  let(:contact) { build(:contact_person) }
  subject { described_class.new(contact, {}) }

  it { is_expected.to have_attribute :first_name }
  it { is_expected.to have_attribute :last_name }
  it { is_expected.to have_attribute :comment }
  it { is_expected.to have_attribute :gender }
  it { is_expected.to have_attribute :nobility_title }
  it { is_expected.to have_attribute :professional_title }
  it { is_expected.to have_attribute :maiden_name }
  it { is_expected.to have_attribute :date_of_birth }
  it { is_expected.to have_attribute :date_of_death }
  it { is_expected.to have_attribute :nationality }
  it { is_expected.to have_attribute :organization_name }
  it { is_expected.to have_attribute :organization_type }
  it { is_expected.to have_attribute :organization_category }
  it { is_expected.to have_attribute :organization_industry }
  it { is_expected.to have_attribute :commercial_register_number }
  it { is_expected.to have_attribute :commercial_register_office }

  it { is_expected.to have_many(:addresses) }
  it { is_expected.to have_many(:mandate_members) }
  it { is_expected.to have_many(:documents) }
  it { is_expected.to have_many(:contact_details) }
  it { is_expected.to have_one(:compliance_detail) }
  it { is_expected.to have_one(:primary_contact_address).with_class_name('Address') }
  it { is_expected.to have_one(:legal_address).with_class_name('Address') }
end