# frozen_string_literal: true

require 'devise/jwt/test_helpers'

RSpec.shared_examples 'state_transitions' do
  describe '#state_transitions' do
    it { is_expected.to have_many(:state_transitions) }
  end
end
