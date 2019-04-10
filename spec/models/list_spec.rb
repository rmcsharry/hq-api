# frozen_string_literal: true

# == Schema Information
#
# Table name: lists
#
#  id         :uuid             not null, primary key
#  user_id    :uuid             not null
#  aasm_state :string           default("active"), not null
#  comment    :text
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_lists_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

require 'rails_helper'

RSpec.describe List, type: :model do
  it { is_expected.to belong_to(:user) }

  it { is_expected.to have_many(:items).class_name('List::Item').dependent(:destroy).inverse_of(:list) }
  it { is_expected.to have_many(:contacts).source(:listable).through(:items) }
  it { is_expected.to have_many(:mandates).source(:listable).through(:items) }

  it { is_expected.to validate_presence_of(:user_id) }
  it { is_expected.to validate_presence_of(:name) }

  describe 'aasm' do
    describe 'initial state' do
      subject { build(:list) }
      it { is_expected.to have_state(:active) }
    end

    describe 'archive event' do
      subject { build(:list, aasm_state: :active) }
      it { is_expected.to transition_from(:active).to(:archived).on_event(:archive) }
    end
  end
end
