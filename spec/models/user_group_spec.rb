# == Schema Information
#
# Table name: user_groups
#
#  id         :uuid             not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  comment    :text
#

require 'rails_helper'

RSpec.describe UserGroup, type: :model do
  describe '#users' do
    it { is_expected.to have_and_belong_to_many(:users) }
  end

  describe '#mandate_groups' do
    it { is_expected.to have_and_belong_to_many(:mandate_groups) }
  end

  describe '#name' do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe '#comment' do
    it { is_expected.to respond_to(:comment) }
  end
end
