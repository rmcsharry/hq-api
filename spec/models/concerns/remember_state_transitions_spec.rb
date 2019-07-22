# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RememberStateTransitions, type: :model do
  let(:subject) { build(:mandate, state: initial_state) }
  let(:initial_state) { :prospect_cold }

  describe 'state_transitions relationship' do
    it { is_expected.to have_many(:state_transitions) }
  end

  describe 'creation of subject' do
    it 'creates a StateTransition' do
      expect do
        subject.save
      end.to(
        change do
          subject.state_transitions.count
        end.by(1)
      )

      expect(subject.state_transitions.first.state.to_sym).to eq(Mandate.aasm.initial_state)
      expect(subject.state_transitions.last.state.to_sym).to eq(initial_state)
    end
  end

  describe 'direct update of subject' do
    let(:subject) { create(:mandate, state: initial_state) }

    it 'triggers creation of a StateTransition if state changes' do
      new_state = :prospect_warm

      expect do
        subject.state = new_state
        subject.save
      end.to(
        change do
          subject.state_transitions.count
        end.by(1)
      )

      expect(subject.state_transitions.first.state.to_sym).to eq(Mandate.aasm.initial_state)
      expect(subject.state_transitions.last.state.to_sym).to eq(new_state)
    end

    it 'does not create a StateTransition if state does not change' do
      expect do
        subject.save
      end.not_to(
        change do
          subject.state_transitions.count
        end
      )
    end
  end

  describe 'update of subject through events' do
    let(:user) { create(:user) }
    let(:subject) { create(:mandate) }

    it 'triggers creation of a StateTransition if state changes' do
      new_state = :prospect_warm

      expect do
        subject.become_prospect_warm(user)
        subject.save
      end.to(
        change do
          subject.state_transitions.count
        end.by(1)
      )

      expect(subject.state_transitions.first.state.to_sym).to eq(Mandate.aasm.initial_state)
      expect(subject.state_transitions.last.state.to_sym).to eq(new_state)
      expect(subject.state_transitions.last.user).to eq(user)
    end
  end
end
