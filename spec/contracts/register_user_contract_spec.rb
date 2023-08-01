require 'rails_helper'

describe RegisterUserContract do
  subject {
    contract = described_class.new
    contract.call(params)
  }
  let(:params) { {
    'user' => {
      'email' => email,
      'first_name' => first_name,
      'last_name' => last_name,
      'password' => password,
      'password_confirmation' => password_confirmation
    }
  } }
  let(:email) { 'test@example.com' }
  let(:first_name) { 'first_name' }
  let(:last_name) { 'last_name' }
  let(:password) { 'password' }
  let(:password_confirmation) { 'password' }

  it 'does not have any errors' do
    expect(subject.success?).to be true
  end

  context 'mismatch password_confirmation' do
    let(:password_confirmation) { 'password_confirmation' }

    it 'returns password_confirmation error' do
      result = subject

      expect(result.success?).to be false
      expect(result.errors.to_h[:user][:password]).to match_array(['password_confirmation does not match'])
    end
  end

  context 'missing email' do
    let(:email) { '' }

    it 'returns email error' do
      result = subject

      expect(result.success?).to be false
      expect(result.errors.to_h[:user][:email]).to eql(['must be filled'])
    end
  end

  context 'missing first_name' do
    let(:first_name) { '' }

    it 'returns first_name error' do
      result = subject

      expect(result.success?).to be false
      expect(result.errors.to_h[:user][:first_name]).to eql(['must be filled'])
    end
  end

  context 'missing last_name' do
    let(:last_name) { '' }

    it 'returns last_name error' do
      result = subject

      expect(result.success?).to be false
      expect(result.errors.to_h[:user][:last_name]).to eql(['must be filled'])
    end
  end

  context 'missing password' do
    let(:password) { '' }

    it 'returns password error' do
      result = subject

      expect(result.success?).to be false
      expect(result.errors.to_h[:user][:password]).to eql(['must be filled'])
    end
  end

  context 'missing password_confirmation' do
    let(:password_confirmation) { '' }

    it 'returns password_confirmation error' do
      result = subject

      expect(result.success?).to be false
      expect(result.errors.to_h[:user][:password_confirmation]).to eql(['must be filled'])
    end
  end
end
