require 'rails_helper'

describe Companies::Create do
  let(:service) { described_class.new(name: company_name, owner: owner_attr) }
  let(:company_name) { 'company' }
  let(:owner_attr) { { email: email, password: password, first_name: first_name, last_name: last_name } }
  let(:email) { 'test@example.com' }
  let(:password) { 'password' }
  let(:first_name) { 'first_name' }
  let(:last_name) { 'last_name' }
  let(:create_user_service) { double(call: nil, success?: true, data: user) }
  let(:user) { create(:user) }

  before do
    allow(Users::Create).to receive(:new).and_return(create_user_service)
  end

  context 'success' do
    it 'calls Users::Create to create user record for the owner' do
      service.call
      company_id = Company.last.id

      expect(Users::Create).to have_received(:new).with(owner_attr.merge(company_id: company_id))
      expect(create_user_service).to have_received(:call)
    end

    it 'creates a new company record' do
      expect{ service.call }.to change{ Company.count }.by(1)

      expect(service.success?).to be true
      expect(service.data.id).to eql(Company.last.id)
    end

    it 'creates company that belongs to created user' do
      service.call

      expect(service.data.owner_id).to eql(user.id)
    end
  end

  context 'failed' do
    context 'failed to create owner record' do
      let(:create_user_service) { double(call: nil, success?: false) }

      it 'does not create company' do
        expect{ service.call }.to_not change{ Company.count }
      end

      it 'returns error' do
        service.call

        expect(service.success?).to be false
        expect(service.error_messages).to eql(['cannot_create_owner'])
      end
    end

    context 'failed to create owner record' do
      before do
        allow(Company).to receive(:create!).and_raise(ActiveRecord::ActiveRecordError.new('failed'))
        allow(Users::Create).to receive(:new).and_call_original
      end

      it 'returns error' do
        service.call

        expect(service.success?).to be false
        expect(service.error_messages).to eql(['failed'])
      end

      it 'does not create any new record' do
        expect{ service.call }.to_not change{
          [User.count, Authentication::Account.count, Company.count]
        }
      end
    end
  end
end
