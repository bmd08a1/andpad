require 'rails_helper'

describe Authentication::Refresh do
  let(:service) { described_class.new(access_token: access_token, refresh_token: refresh_token) }
  let(:access_token) { SecureRandom.uuid }
  let(:refresh_token) { SecureRandom.uuid }
  let!(:old_token) { create(:access_token, token: access_token, refresh_token: refresh_token, user_id: user_id) }
  let(:user_id) { SecureRandom.uuid }

  context 'success' do
    it 'creates a new access token' do
      service.call

      new_token = Authentication::AccessToken.order(:created_at).last
      expect(new_token.user_id).to eql(user_id)

      expect(Authentication::AccessToken.find_by(id: old_token.id)).to be nil
    end

    it 'returns new access token data' do
      service.call

      new_token = Authentication::AccessToken.order(:created_at).last

      expect(service.success?).to be true
      expect(service.data[:access_token]).to eql(new_token.token)
      expect(service.data[:refresh_token]).to eql(new_token.refresh_token)
      expect(service.data[:expires_in]).to eql(new_token.expires_in.to_i)
    end
  end

  context 'failed' do
    context 'invalid access_token' do
      let!(:old_token) { create(:access_token, refresh_token: refresh_token, user_id: user_id) }

      it 'returns error' do
        service.call

        expect(service.success?).to be false
        expect(service.error_messages).to eql(['cannot_refresh_token'])
      end
    end

    context 'invalid refresh_token' do
      let!(:old_token) { create(:access_token, token: access_token, user_id: user_id) }

      it 'returns error' do
        service.call

        expect(service.success?).to be false
        expect(service.error_messages).to eql(['cannot_refresh_token'])
      end
    end

    context 'generate access token failed' do
      before do
        allow(Authentication::AccessToken).to receive(:create!).and_raise(ActiveRecord::ActiveRecordError.new('failed'))
      end

      it 'returns error' do
        service.call

        expect(service.success?).to be false
        expect(service.error_messages).to eql(['cannot_refresh_token'])
      end
    end
  end
end
