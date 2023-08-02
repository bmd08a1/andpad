require 'rails_helper'

RSpec.configure do |c|
  c.include AuthenticationHelper
end

RSpec.describe AuthenticationHelper do
  describe '.require_login' do
    let(:request) { double(headers: headers) }

    context 'valid' do
      let(:headers) { { 'token' => 'abc' } }

      it 'does not raise any error' do
        expect{ require_login }.to_not raise_error
      end
    end

    context 'missing token headers' do
      let(:headers) { {} }

      it 'raise UnauthenticatedError' do
        expect{ require_login }.to raise_error(AuthenticationHelper::UnauthenticatedError)
      end
    end

    context 'empty token header' do
      let(:headers) { { 'token' => '' } }

      it 'raise UnauthenticatedError' do
        expect{ require_login }.to raise_error(AuthenticationHelper::UnauthenticatedError)
      end
    end
  end

  describe '.current_user' do
    context 'valid token' do
      let(:user) { create(:user, company_id: company.id) }
      let(:company) { create(:company) }
      let!(:access_token) { create(:access_token, token: token, user_id: user.id) }
      let(:token) { SecureRandom.uuid }
      let(:request) { double(headers: { 'token' => token }) }

      it 'returns user details' do
        result = current_user

        expect(result.id).to eql(user.id)
        expect(result.company_id).to eql(company.id)
        expect(result.is_owner).to be false
        expect(result.is_manager).to be false
        expect(result.managed_team).to be nil
        expect(result.member_of).to be nil
      end
    end

    context 'invalid token' do
      let(:user) { create(:user, company_id: company.id) }
      let(:company) { create(:company) }
      let!(:access_token) { create(:access_token, token: token, user_id: user.id) }
      let(:token) { SecureRandom.uuid }
      let(:request) { double(headers: { 'token' => 'invalid' }) }

      it 'raise UnauthenticatedError' do
        expect{ current_user }.to raise_error(AuthenticationHelper::UnauthenticatedError)
      end
    end

    context 'expired token' do
      let(:user) { create(:user, company_id: company.id) }
      let(:company) { create(:company) }
      let!(:access_token) { create(:access_token, token: token, user_id: user.id, created_at: (Time.now - 31.minutes).to_i) }
      let(:token) { SecureRandom.uuid }
      let(:request) { double(headers: { 'token' => token }) }

      it 'raise UnauthenticatedError' do
        expect{ current_user }.to raise_error(AuthenticationHelper::UnauthenticatedError)
      end
    end
  end
end
