require 'rails_helper'

describe Users::Create do
  let(:service) { described_class.new(email: email, password: password, first_name: first_name, last_name: last_name,
                                     company_id: company_id) }
  let(:email) { 'test@example.com' }
  let(:password) { 'password' }
  let(:first_name) { 'first_name' }
  let(:last_name) { 'last_name' }
  let(:company_id) { SecureRandom.uuid }

  context 'success' do
    it 'creates a user and a an account records' do
      expect{ service.call }.to change {
        [User.count, Authentication::Account.count]
      }.from([0, 0]).to([1, 1])

      expect(service.success?).to be true
    end

    it 'creates user with input value' do
      service.call

      user = User.last
      expect(user.email).to eql('test@example.com')
      expect(user.first_name).to eql('first_name')
      expect(user.last_name).to eql('last_name')
      expect(user.company_id).to eql(company_id)
    end

    it 'creates account links with created user and correct password' do
      service.call

      user = User.last
      account = Authentication::Account.where(user_id: user.id).last
      expect(account.authenticate('password')).to be true
    end
  end

  context 'failed' do
    context 'create user record failed' do
      before do
        allow(User).to receive(:create!).and_raise(ActiveRecord::ActiveRecordError.new('failed'))
      end

      it 'does not create any records and return errors' do
        expect{ service.call }.to_not change {
          [User.count, Authentication::Account.count]
        }

        expect(service.success?).to be false
        expect(service.error_messages).to eql(['failed'])
      end
    end

    context 'create account record failed' do
      before do
        allow(Authentication::Account).to receive(:create!).and_raise(ActiveRecord::ActiveRecordError.new('failed'))
      end

      it 'does not create any records and return errors' do
        expect{ service.call }.to_not change {
          [User.count, Authentication::Account.count]
        }

        expect(service.success?).to be false
        expect(service.error_messages).to eql(['failed'])
      end
    end
  end
end
