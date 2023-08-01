require 'rails_helper'

RSpec.describe 'Users', type: :request do
  let(:json_response) { JSON.parse(response.body) }

  describe 'POST /users' do
    let(:path) { '/users' }
    let(:params) { {
      'user' => {
        'email' => 'test@example.com',
        'first_name' => 'first_name',
        'last_name' => 'last_name',
        'password' => 'password',
        'password_confirmation' => 'password'
      }
    } }

    context 'success' do
      it 'creates users profile and accounts' do
        expect{ post path, params: params, as: :json }.to change {
          [User.count, Authentication::Account.count]
        }.from([0, 0]).to([1, 1])

        expect(json_response['success']).to be true
      end

      it 'creates user profile with correct value' do
        post path, params: params, as: :json

        user = User.last
        expect(user.email).to eql('test@example.com')
        expect(user.first_name).to eql('first_name')
        expect(user.last_name).to eql('last_name')
      end

      it 'create users accont with correct password' do
        post path, params: params, as: :json

        account = Authentication::Account.last
        expect(account.authenticate('password')).to be true
      end
    end

    context 'failed' do
      context 'params contract failed' do
        let(:params) { {
          'user' => {
            'email' => 'test@example.com',
            'first_name' => 'first_name',
            'last_name' => 'last_name',
            'password' => 'password',
          }
        } }

        it 'does not create any records and return errors' do
          expect{ post path, params: params, as: :json }.to_not change {
            [User.count, Authentication::Account.count]
          }

          expect(json_response['success']).to be false
          expect(json_response['error_messages']).to eql({ 'user' => { 'password_confirmation' => ['is missing'] } })
          expect(response.status).to eql(400)
        end
      end

      context 'create user record failed' do
        before do
          allow(User).to receive(:create!).and_raise(ActiveRecord::ActiveRecordError.new('failed'))
        end

        it 'does not create any records and return errors' do
          expect{ post path, params: params, as: :json }.to_not change {
            [User.count, Authentication::Account.count]
          }

          expect(json_response['success']).to be false
          expect(json_response['error_messages']).to eql(['failed'])
          expect(response.status).to eql(422)
        end
      end

      context 'create account record failed' do
        before do
          allow(Authentication::Account).to receive(:create!).and_raise(ActiveRecord::ActiveRecordError.new('failed'))
        end

        it 'does not create any records and return errors' do
          expect{ post path, params: params, as: :json }.to_not change {
            [User.count, Authentication::Account.count]
          }

          expect(json_response['success']).to be false
          expect(json_response['error_messages']).to eql(['failed'])
          expect(response.status).to eql(422)
        end
      end
    end
  end
end
