require 'rails_helper'

describe Authentication::Login do
  let(:service) { described_class.new(email: email, password: password) }
  let(:email) { 'test@example.com' }
  let(:password) { 'password' }

  context 'success' do
    let(:user) { create(:user, email: email) }
    let!(:account) { create(:account, password: password, user_id: user.id) }

    it 'creates a new access token' do
      expect{ service.call }.to change{
        Authentication::AccessToken.where(user_id: user.id).count
      }.by(1)
    end

    it 'returns access token data' do
      service.call

      token = Authentication::AccessToken.where(user_id: user.id).last

      expect(service.success?).to be true
      expect(service.data[:access_token]).to eql(token.token)
      expect(service.data[:refresh_token]).to eql(token.refresh_token)
      expect(service.data[:expires_in]).to eql(token.expires_in.to_i)
    end
  end

  context 'failed' do
    context 'cannot find user with email' do
      it 'returns error' do
        service.call

        expect(service.success?).to be false
        expect(service.error_messages).to eql(['invalid_email_and_password'])
      end
    end

    context 'invalid password' do
      let(:user) { create(:user, email: email) }
      let!(:account) { create(:account, user_id: user.id, password: 'invalid_password') }

      it 'returns error' do
        service.call

        expect(service.success?).to be false
        expect(service.error_messages).to eql(['invalid_email_and_password'])
      end
    end

    context 'generate access token failed' do
      let(:user) { create(:user, email: email) }
      let!(:account) { create(:account, password: password, user_id: user.id) }

      before do
        allow(Authentication::AccessToken).to receive(:create!).and_raise(ActiveRecord::ActiveRecordError.new('failed'))
      end

      it 'returns error' do
        service.call

        expect(service.success?).to be false
        expect(service.error_messages).to eql(['failed'])
      end
    end
  end
end
