# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :uuid             not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  failed_attempts        :integer          default(0), not null
#  unlock_token           :string
#  locked_at              :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  invitation_token       :string
#  invitation_created_at  :datetime
#  invitation_sent_at     :datetime
#  invitation_accepted_at :datetime
#  invitation_limit       :integer
#  invited_by_type        :string
#  invited_by_id          :bigint(8)
#  invitations_count      :integer          default(0)
#  comment                :text
#  contact_id             :uuid
#  ews_user_id            :string
#  deactivated_at         :datetime
#
# Indexes
#
#  index_users_on_confirmation_token                 (confirmation_token) UNIQUE
#  index_users_on_contact_id                         (contact_id)
#  index_users_on_email                              (email) UNIQUE
#  index_users_on_invitation_token                   (invitation_token) UNIQUE
#  index_users_on_invitations_count                  (invitations_count)
#  index_users_on_invited_by_id                      (invited_by_id)
#  index_users_on_invited_by_type_and_invited_by_id  (invited_by_type,invited_by_id)
#  index_users_on_reset_password_token               (reset_password_token) UNIQUE
#  index_users_on_unlock_token                       (unlock_token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (contact_id => contacts.id)
#

require 'rails_helper'

RSpec.describe User, type: :model do
  it { is_expected.to respond_to(:comment) }

  describe '#contact' do
    it { is_expected.to belong_to(:contact) }
  end

  describe '#user_groups' do
    it { is_expected.to have_and_belong_to_many(:user_groups) }
  end

  describe '#activities' do
    it { is_expected.to have_many(:activities) }
  end

  describe '#user_group_count' do
    subject { create(:user) }
    let!(:user_groups) { create_list(:user_group, 3, users: [subject]) }

    it 'counts 3 user groups' do
      expect(User.with_user_group_count.where(id: subject.id).first.user_group_count).to eq 3
    end
  end

  describe '#email' do
    subject { create(:user, email: 'USER@hqfinanz.de') }

    it 'saves email downcased' do
      expect(subject.email).to eq 'user@hqfinanz.de'
    end

    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_presence_of(:email) }
  end

  describe '#setup_ews_id' do
    before do
      Timecop.freeze(Time.zone.local(2018, 8, 14, 12))
    end

    after do
      Timecop.return
    end

    let(:id_token) do
      <<~TOKEN
        eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6IklENl9ZMzFzaVhhSnFLOW9QUmpVbUpNQzN5TSJ9.eyJhcHBjdHhzZW5kZXIiOiIwMDAwMDAwMi0wMDAwLTBmZjEtY2UwMC0wMDAwMDAwMDAwMDBAdmVydGljYWwucm9vdCIsImlzYnJvd3Nlcmhvc3RlZGFwcCI6IlRydWUiLCJhcHBjdHgiOiJ7XCJtc2V4Y2h1aWRcIjpcIjAwOGMyMjY5LTI2NzYtNDJhMi05ZjVkLWQyZTYwZWQ4NWIyOFwiLFwidmVyc2lvblwiOlwiRXhJZFRvay5WMVwiLFwiYW11cmxcIjpcImh0dHBzOi8vb3V0bG9vay5vbnZlcnRpY2FsLmNvbTo0NDMvYXV0b2Rpc2NvdmVyL21ldGFkYXRhL2pzb24vMVwifSIsImlzcyI6IjAwMDAwMDAyLTAwMDAtMGZmMS1jZTAwLTAwMDAwMDAwMDAwMEB2ZXJ0aWNhbC5yb290IiwiYXVkIjoiaHR0cHM6Ly9sb2NhbGhvc3Q6MzAwMi9pbmRleC5odG1sIiwiZXhwIjoxNTM0MjU4NDM4LCJuYmYiOjE1MzQyMjk2Mzh9.no07Bprg24FMxn4zLxhtTE0PXRab9cXenrd9vOOVnCkxq2FPXflOEoDktCXMvM9P9zX-WdXYq2_kyb9Xo9o83UqxsRF-GS18D5GMXYrZazkDLV_5F0gcOv9yx-g5petIrBm-IcQfcB4yg3VtzeSnmDsRBHnCB_Z1EIh53dQ88l2pj2b7hmVR336akHa6j6maY4ubQvebNvWP_Wj3zljX2_4p91TvWb65oBSR2F0du4PpYRqZZ4eK0_EQ10-_TZ27eD4LL__skTTvXYd-OtbCDQM8_mZARVjdyeBVLCLcMSIm_t3yI5nw2DifT6MvM-ttabjW1LkTaaaL4ZSsp3UDUQ
      TOKEN
    end

    # The msexchuid encoded in the identity token above
    let(:msexchuid) { '008c2269-2676-42a2-9f5d-d2e60ed85b28' }

    context 'when ews_user_id exists' do
      subject { create(:user, ews_user_id: 'not-updated') }

      it 'does not update the ews_user_id' do
        subject.setup_ews_id id_token
        expect(subject.ews_user_id).to eq('not-updated')
      end
    end

    context 'when ews_user_id does not exist' do
      subject { create(:user, ews_user_id: nil) }

      it 'sets the ews_user_id if id_token is valid' do
        subject.setup_ews_id id_token
        expect(subject.ews_user_id).to eq(msexchuid)
      end

      it 'does not set the ews_user_id if id_token is invalid' do
        subject.setup_ews_id 'a.b.c'
        expect(subject.ews_user_id).to eq(nil)
      end
    end
  end

  describe '#deactivated_at' do
    subject { create(:user) }

    it 'disables login' do
      expect(subject.active_for_authentication?).to eq true
      subject.deactivated_at = Time.zone.now
      subject.save!
      expect(subject.active_for_authentication?).to eq false
    end

    it '#deactivate!' do
      expect(subject.active_for_authentication?).to eq true
      subject.deactivate!
      expect(subject.active_for_authentication?).to eq false
    end

    it '#reactivate!' do
      subject.deactivate!
      expect(subject.active_for_authentication?).to eq false
      subject.reactivate!
      expect(subject.active_for_authentication?).to eq true
    end
  end
end
