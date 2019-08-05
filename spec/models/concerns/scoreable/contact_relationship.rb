# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scoreable::ContactRelationship do
  describe '#rescore_owner' do
    before(:all) do
      ContactRelationship.set_callback(:commit, :after, :rescore_owner)
    end

    after(:all) do
      ContactRelationship.skip_callback(:commit, :after, :rescore_owner)
    end

    describe 'for contact_relationship' do
      let!(:subject) { create(:contact_organization) }
      let!(:relationship_1) { build(:contact_relationship, role: 'shareholder') }
      let!(:relationship_2) { build(:contact_relationship, role: 'shareholder') }
      let!(:relationship_3) { build(:contact_relationship, role: 'bookkeeper') }

      context 'when rule: a related model property has a specific value (role == shareholder)' do
        it 'is correct when relationship is added' do
          relationship_1.target_contact = subject
          subject.passive_contact_relationships << relationship_1
          relationship_1.save!

          expect(subject.data_integrity_missing_fields).not_to include('shareholder')
          expect(subject.data_integrity_missing_fields.length).to eq(20)
          expect(subject.data_integrity_score).to be_within(0.0001).of(0.1698)
        end

        it 'is not rescored when existing role is added again' do
          relationship_1.target_contact = subject
          subject.passive_contact_relationships << relationship_1

          expect(subject).not_to receive(:calculate_score)
          relationship_2.target_contact = subject
          subject.passive_contact_relationships << relationship_2
        end

        it 'is not rescored when a non-rule role is added' do
          expect(subject).not_to receive(:calculate_score)
          relationship_3.target_contact = subject
          subject.passive_contact_relationships << relationship_3
        end
      end
    end
  end
end
