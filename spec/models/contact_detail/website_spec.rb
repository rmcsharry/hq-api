# frozen_string_literal: true

# == Schema Information
#
# Table name: contact_details
#
#  id         :uuid             not null, primary key
#  type       :string
#  category   :string
#  value      :string
#  primary    :boolean          default(FALSE), not null
#  contact_id :uuid
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_contact_details_on_contact_id  (contact_id)
#
# Foreign Keys
#
#  fk_rails_...  (contact_id => contacts.id)
#

require 'rails_helper'

RSpec.describe ContactDetail::Website, type: :model do
  subject { build(:website) }

  describe '#value' do
    let(:valid_urls) { ['www.hqtrust.de', 'https://hqtrust.de', 'http://www.hqfinanz.de'] }
    let(:invalid_urls) { ['ftp://test.de', 'https://de'] }

    it 'validates URL format' do
      expect(subject).to allow_values(*valid_urls).for(:value)
      expect(subject).not_to allow_values(*invalid_urls).for(:value)
    end

    it 'normalizes URL before validation' do
      subject.value = 'wWw.hQtrusT.dE'
      subject.valid?
      expect(subject.value).to eq 'https://www.hqtrust.de'
    end
  end
end
