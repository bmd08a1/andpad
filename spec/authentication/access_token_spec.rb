require 'rails_helper'

describe Authentication::AccessToken, type: :model do
  describe '.generate' do
    let(:user_id) { SecureRandom.uuid }

    it 'generates a new access token for the user' do
      expect{ described_class.generate(user_id) }.to change{
        Authentication::AccessToken.where(user_id: user_id).count
      }.by(1)
    end
  end

  describe '.refresh' do
    let!(:old_token) { create(:access_token, token: token, refresh_token: refresh_token) }
    let(:token) { SecureRandom.uuid }
    let(:refresh_token) { SecureRandom.uuid }

    it 'deletes old access token and generate a new one' do
      new_token = described_class.refresh(token, refresh_token)

      expect(Authentication::AccessToken.find_by(id: old_token.id)).to be nil

      expect(new_token.user_id).to eql(old_token.user_id)
      expect(new_token.token).to_not eql(token)
      expect(new_token.refresh_token).to_not eql(refresh_token)
    end
  end

  describe '#expires_in' do
    let(:access_token) { create(:access_token) }

    before do
      allow(Time).to receive(:now).and_return(Time.at(1690949676))
    end

    it 'returns number of seconds until token expired' do
      expect(access_token.expires_in).to eql(1800.0)
    end
  end
end
