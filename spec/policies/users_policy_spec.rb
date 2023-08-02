require 'rails_helper'

RSpec.describe UsersPolicy do
  let(:policy) { described_class.new(current_user) }
  let(:current_user) { double(is_owner: is_owner, is_manager: is_manager) }
  let(:is_owner) { true }
  let(:is_manager) { true }

  describe '#can_create?' do
    context 'is owner' do
      let(:is_manager) { false }

      it 'returns true' do
        expect(policy.can_create?).to be true
      end
    end

    context 'is manager' do
      let(:is_owner) { false }

      it 'returns true' do
        expect(policy.can_create?).to be true
      end
    end

    context 'not manager nor owner' do
      let(:is_owner) { false }
      let(:is_manager) { false }

      it 'returns false' do
        expect(policy.can_create?).to be false
      end
    end
  end
end
