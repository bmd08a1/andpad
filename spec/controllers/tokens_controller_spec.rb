require 'rails_helper'

RSpec.describe 'Tokens', type: :request do
  let(:json_response) { JSON.parse(response.body) }

  describe 'POST /login' do
    let(:path) { '/login' }
    let(:params) { {
      'email' => 'test@example.com',
      'password' => 'password',
    } }
    subject { post path, params: params, as: :json }

    context 'success' do
      let(:user) { create(:user, email: 'test@example.com') }
      let!(:account) { create(:account, password: 'password', user_id: user.id) }

      it 'creates access token' do
        expect{ subject }.to change { Authentication::AccessToken.count }
      end

      it 'returns access token details' do
        subject

        access_token = Authentication::AccessToken.last
        expect(json_response['data']['access_token']).to eql(access_token.token)
        expect(json_response['data']['refresh_token']).to eql(access_token.refresh_token)
        expect(json_response['data']['expires_in']).to eql(access_token.expires_in.to_i)
      end
    end

    context 'failed' do
      context 'params contract failed' do
        let(:params) { {
            'email' => 'test@example.com',
        } }

        it 'does not create any records and return errors' do
          expect{ subject }.to_not change { Authentication::AccessToken.count }

          expect(json_response['success']).to be false
          expect(json_response['error_messages']).to eql({ 'password' => ['is missing'] })
          expect(response.status).to eql(400)
        end
      end

      context 'create tokens failed' do
        let(:service) { double(call: nil, success?: false, error_messages: ['failed']) }
        before do
          allow(Authentication::Login).to receive(:new).and_return(service)
        end

        it 'return errors' do
          subject

          expect(Authentication::Login).to have_received(:new).with(
            email: 'test@example.com', password: 'password'
          )
          expect(service).to have_received(:call)
          expect(response.status).to eql(422)
          expect(json_response['error_messages']).to eql(['failed'])
        end
      end
    end
  end
end
