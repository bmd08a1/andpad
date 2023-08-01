require 'rails_helper'

describe Authentication::Account, type: :model do
  describe 'validation' do
    subject { create(:account) }

    it { is_expected.to validate_presence_of :password }
    it { is_expected.to validate_length_of(:password).is_at_least(6) }
  end

  describe '#authenticate' do
    let(:account) { create(:account, password: 'password') }

    context 'valid password' do
      it 'returns true' do
        expect(account.authenticate('password')).to be true
      end
    end

    context 'invalid password' do
      it 'returns true' do
        expect(account.authenticate('invalid')).to be false
      end
    end
  end

  describe '#password=' do
    let(:account) { build(:account, password: nil) }

    it 'stores input password' do
      account.password = 'password'

      expect(account.authenticate('password')).to be true
      expect(account.authenticate('not_password')).to be false
    end
  end
end
