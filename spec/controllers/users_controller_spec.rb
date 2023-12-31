require 'rails_helper'

RSpec.describe 'Users', type: :request do
  let(:json_response) { JSON.parse(response.body) }

  describe 'POST /users' do
    subject { post path, params: params, headers: headers, as: :json }
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
    let(:headers) { { 'token' => access_token.token } }
    let(:access_token) { create(:access_token, user_id: user.id) }
    let!(:user) { create(:user, company_id: company.id) }
    let(:company) { create(:company) }

    before do
      company.update(owner_id: user.id)
    end

    context 'success' do
      it 'creates users profile and accounts' do
        expect{ subject }.to change {
          [User.count, Authentication::Account.count]
        }.from([1, 0]).to([2, 1])

        expect(json_response['success']).to be true
      end

      it 'creates user profile with correct value' do
        subject

        user = User.order(created_at: :asc).last
        expect(user.email).to eql('test@example.com')
        expect(user.first_name).to eql('first_name')
        expect(user.last_name).to eql('last_name')
        expect(user.company_id).to eql(company.id)
      end

      it 'create users accont with correct password' do
        subject

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
          expect{ subject }.to_not change {
            [User.count, Authentication::Account.count]
          }

          expect(json_response['success']).to be false
          expect(json_response['error_messages']).to eql({ 'password_confirmation' => ['is missing'] })
          expect(response.status).to eql(400)
        end
      end

      context 'create user record failed' do
        before do
          allow(User).to receive(:create!).and_raise(ActiveRecord::ActiveRecordError.new('failed'))
        end

        it 'does not create any records and return errors' do
          expect{ subject }.to_not change {
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
          expect{ subject }.to_not change {
            [User.count, Authentication::Account.count]
          }

          expect(json_response['success']).to be false
          expect(json_response['error_messages']).to eql(['failed'])
          expect(response.status).to eql(422)
        end
      end

      context 'token headers missing' do
        let(:headers) { {} }

        it 'returns error' do
          expect{ subject }.to_not change {
            [User.count, Authentication::Account.count]
          }

          expect(json_response['error_messages']).to eql(['Unauthenticated'])
          expect(response.status).to eql(401)
        end
      end

      context 'current_user is not allowed to create users' do
        before do
          company.update(owner_id: SecureRandom.uuid)
        end

        it 'returns error' do
          expect{ subject }.to_not change {
            [User.count, Authentication::Account.count]
          }

          expect(json_response['error_messages']).to eql(['unauthorized'])
          expect(response.status).to eql(403)
        end
      end
    end
  end

  describe 'GET /users' do
    subject { get path, headers: headers, as: :json }
    let(:path) { '/users' }
    let(:headers) { { 'token' => access_token.token } }
    let(:access_token) { create(:access_token, user_id: user.id) }
    let!(:user) { create(:user, company_id: company.id) }
    let(:company) { create(:company) }
    let!(:company_users) {
      [
        create(:user, email: 'manager@example.com', first_name: 'manager', company_id: company.id),
        create(:user, email: 'member@example.com', first_name: 'member', company_id: company.id)
      ]
    }
    let!(:team) { create(:team, company_id: company.id, manager_id: company_users[0].id) }
    let!(:member) { create(:member, team_id: team.id, user_id: company_users[1].id) }
    let!(:other_user) { create(:user, email: 'other@example.com', company_id: create(:company, name: 'other').id ) }

    it 'returns same company users data' do
      subject

      expect(json_response['data'].count).to eql(3)
      expect(json_response['data']).to match_array([
        { 'user_id' => user.id, 'email' => user.email, 'user_name' => user.first_name + ' ' + user.last_name,
        'is_manager' => false, 'member_of' => nil, 'managed_team' => nil },
        { 'user_id' => company_users[0].id, 'email' => company_users[0].email, 'user_name' => company_users[0].first_name + ' ' + company_users[0].last_name,
          'is_manager' => true, 'member_of' => nil, 'managed_team' => { 'team_id' => team.id, 'team_name' => team.name } },
        { 'user_id' => company_users[1].id, 'email' => company_users[1].email, 'user_name' => company_users[1].first_name + ' ' + company_users[1].last_name,
          'is_manager' => false, 'member_of' => { 'team_id' => team.id, 'team_name' => team.name }, 'managed_team' => nil  },
      ])
    end
  end
end
