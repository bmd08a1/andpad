require 'rails_helper'

RSpec.describe 'Teams', type: :request do
  let(:json_response) { JSON.parse(response.body) }

  describe 'POST /teams' do
    subject { post path, params: params, headers: headers, as: :json }
    let(:path) { '/teams' }
    let(:params) { {
      'team' => {
        'name' => 'name',
        'manager_id' => manager_id,
      }
    } }
    let(:manager_id) { SecureRandom.uuid }
    let(:headers) { { 'token' => access_token.token } }
    let(:access_token) { create(:access_token, user_id: current_user.id) }
    let!(:current_user) { create(:user, company_id: company.id) }
    let(:company) { create(:company) }
    let!(:manager) { create(:user, email: 'manager@example.com', id: manager_id, company_id: company.id) }

    before do
      company.update(owner_id: current_user.id)
    end

    context 'success' do
      it 'creates a new team' do
        expect{ subject }.to change { CompanyStructure::Team.count }.by(1)

        expect(json_response['success']).to be true
      end

      it 'creates new team with correct manager_id' do
        subject

        team = CompanyStructure::Team.last
        expect(team.name).to eql('name')
        expect(team.manager_id).to eql(manager_id)
      end
    end

    context 'failed' do
      context 'params contract failed' do
        let(:params) { {
          'team' => {
            'name' => 'name',
          }
        } }

        it 'does not create any records and return errors' do
          expect{ subject }.to_not change { CompanyStructure::Team.count }

          expect(json_response['success']).to be false
          expect(json_response['error_messages']).to eql({ 'manager_id' => ['is missing'] })
          expect(response.status).to eql(400)
        end
      end

      context 'create team record failed' do
        before do
          allow(CompanyStructure::Team).to receive(:create).and_return(
            double(persisted?: false, errors: double(messages: ['failed']))
          )
        end

        it 'does not create any records and return errors' do
          expect{ subject }.to_not change { CompanyStructure::Team.count }

          expect(json_response['success']).to be false
          expect(json_response['error_messages']).to eql(['failed'])
          expect(response.status).to eql(422)
        end
      end

      context 'token headers missing' do
        let(:headers) { {} }

        it 'returns error' do
          expect{ subject }.to_not change { CompanyStructure::Team.count }

          expect(json_response['error_messages']).to eql(['Unauthenticated'])
          expect(response.status).to eql(401)
        end
      end

      context 'current_user is not allowed to create teams' do
        before do
          company.update(owner_id: SecureRandom.uuid)
        end

        it 'returns error' do
          expect{ subject }.to_not change { CompanyStructure::Team.count }

          expect(json_response['error_messages']).to eql(['unauthorized'])
          expect(response.status).to eql(403)
        end
      end

      context 'current_user is not allowed to create teams for this manager' do
        let!(:manager) { create(:user, email: 'manager@example.com', id: manager_id) }

        it 'returns error' do
          expect{ subject }.to_not change { CompanyStructure::Team.count }

          expect(json_response['error_messages']).to eql(['unauthorized'])
          expect(response.status).to eql(403)
        end
      end
    end
  end

  describe 'GET /teams' do
    subject { get path, headers: headers, as: :json }
    let(:path) { '/teams' }
    let(:headers) { { 'token' => access_token.token } }
    let(:access_token) { create(:access_token, user_id: current_user.id) }
    let!(:current_user) { create(:user, company_id: company.id) }
    let(:company) { create(:company) }
    let!(:teams) {
      [
        create(:team, name: 'abc', manager_id: managers[0].id),
        create(:team, name: 'bcd', manager_id: managers[1].id),
        create(:team, name: 'cde', manager_id: managers[2].id)
      ]
    }
    let(:managers) {
      [
        create(:user, first_name: 'manager_1', email: 'manager1@gmail.com', company_id: company.id),
        create(:user, first_name: 'manager_2', email: 'manager2@gmail.com', company_id: company.id),
        create(:user, first_name: 'manager_3', email: 'manager3@gmail.com', company_id: company.id),
      ]
    }

    it 'returns teams data' do
      subject

      expect(json_response['data'].count).to eql(3)
      (0..2).each do |i|
        expect(json_response['data'][i]['manager_first_name']).to eql(managers[i].first_name)
        expect(json_response['data'][i]['manager_last_name']).to eql(managers[i].last_name)
        expect(json_response['data'][i]['team_name']).to eql(teams[i].name)
        expect(json_response['data'][i]['team_id']).to eql(teams[i].id)
      end
    end
  end
end
