require 'rails_helper'

RSpec.describe V1::ComplianceDetailResource, type: :resource do
  let(:compliance_detail) { create(:compliance_detail) }
  subject { described_class.new(compliance_detail, {}) }

  it { is_expected.to have_attribute :wphg_classification }
  it { is_expected.to have_attribute :kagb_classification }
  it { is_expected.to have_attribute :politically_exposed }
  it { is_expected.to have_attribute :occupation_role }
  it { is_expected.to have_attribute :occupation_title }
  it { is_expected.to have_attribute :retirement_age }

  it { is_expected.to have_one(:contact) }
end
