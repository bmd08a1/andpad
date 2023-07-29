require 'rails_helper'

describe Authentication::Credentials do
  describe '#authenticate' do
    let(:credentials) { create(:credentials, password: 'password') }

    context 'valid password' do
      it 'returns true' do
        expect(credentials.authenticate('password')).to be true
      end
    end

    context 'invalid password' do
      it 'returns true' do
        expect(credentials.authenticate('invalid')).to be false
      end
    end
  end

  describe '#password=' do
    let(:credentials) { build(:credentials, password: nil) }

    it 'stores input password' do
      credentials.password = 'password'

      expect(credentials.authenticate('password')).to be true
      expect(credentials.authenticate('not_password')).to be false
    end
  end
end
