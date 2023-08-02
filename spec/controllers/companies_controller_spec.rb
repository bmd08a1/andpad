require 'rails_helper'

RSpec.describe 'Companies', type: :request do
  let(:json_response) { JSON.parse(response.body) }

  describe 'POST /companies/register' do
    subject { post path, params: params, as: :json }
    let(:path) { '/companies/register' }
    let(:params) { {
      'company' => {
        'name' => 'company_name',
        'owner' => {
          'email' => 'test@example.com',
          'first_name' => 'first_name',
          'last_name' => 'last_name',
          'password' => 'password',
          'password_confirmation' => 'password'
        }
      }
    } }

    context 'success' do
      it 'creates company and owner records' do
        expect{ subject }.to change {
          [Company.count, User.count, Authentication::Account.count]
        }.from([0, 0, 0]).to([1, 1, 1])

        expect(json_response['success']).to be true
      end

      it 'creates company profile with correct value' do
        subject

        company = Company.last
        expect(company.name).to eql('company_name')
        expect(company.owner_id).to eql(User.last.id)
      end

      it 'creates user profile with correct value' do
        subject

        user = User.last
        expect(user.email).to eql('test@example.com')
        expect(user.first_name).to eql('first_name')
        expect(user.last_name).to eql('last_name')
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
          'company' => {
            'name' => 'company_name',
            'owner' => {
              'email' => 'test@example.com',
              'first_name' => 'first_name',
              'last_name' => 'last_name',
              'password' => 'password',
            }
          }
        } }

        it 'does not create any records and return errors' do
          expect{ subject }.to_not change {
            [Company.count, User.count, Authentication::Account.count]
          }

          expect(json_response['success']).to be false
          expect(json_response['error_messages']).to eql({ 'company' => { 'owner' => { 'password_confirmation' => ['is missing'] } } })
          expect(response.status).to eql(400)
        end
      end

      context 'create user record failed' do
        before do
          allow(User).to receive(:create!).and_raise(ActiveRecord::ActiveRecordError.new('failed'))
        end

        it 'does not create any records and return errors' do
          expect{ subject }.to_not change {
            [Company.count, User.count, Authentication::Account.count]
          }

          expect(json_response['success']).to be false
          expect(json_response['error_messages']).to eql(['cannot_create_owner'])
          expect(response.status).to eql(422)
        end
      end

      context 'create account record failed' do
        before do
          allow(Authentication::Account).to receive(:create!).and_raise(ActiveRecord::ActiveRecordError.new('failed'))
        end

        it 'does not create any records and return errors' do
          expect{ subject }.to_not change {
            [Company.count, User.count, Authentication::Account.count]
          }

          expect(json_response['success']).to be false
          expect(json_response['error_messages']).to eql(['cannot_create_owner'])
          expect(response.status).to eql(422)
        end
      end

      context 'create company record failed' do
        before do
          allow(Company).to receive(:create!).and_raise(ActiveRecord::ActiveRecordError.new('failed'))
        end

        it 'does not create any records and return errors' do
          expect{ subject }.to_not change {
            [Company.count, User.count, Authentication::Account.count]
          }

          expect(json_response['success']).to be false
          expect(json_response['error_messages']).to eql(['failed'])
          expect(response.status).to eql(422)
        end
      end
    end
  end
end
