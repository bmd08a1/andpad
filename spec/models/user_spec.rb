require 'rails_helper'

RSpec.describe User do
  describe 'validations' do
    subject { create(:user) }

    it { is_expected.to validate_presence_of :first_name }
    it { is_expected.to validate_presence_of :last_name }
    it { is_expected.to validate_presence_of :email }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to allow_value('test@gmail.com').for(:email) }
    it { is_expected.to_not allow_value('test@@gmail.com').for(:email) }
  end
end
