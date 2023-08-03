require 'rails_helper'

describe Teams::AddMember do
  let(:service) { described_class.new(team_id: team_id, member_id: member_id) }
  let(:team_id) { SecureRandom.uuid }
  let(:member_id) { SecureRandom.uuid }
  let(:team_double) { double(add_member: nil) }

  before do
    allow(CompanyStructure::Team).to receive(:find).and_return(team_double)
  end

  it 'calls #add_member on team' do
    service.call

    expect(CompanyStructure::Team).to have_received(:find).with(team_id)
    expect(team_double).to have_received(:add_member).with(member_id)
    expect(service.success?).to be true
  end

  context 'error' do
    before do
      allow(team_double).to receive(:add_member).and_raise(ActiveRecord::ActiveRecordError.new('failed'))
    end

    it 'returns error' do
      service.call

      expect(service.success?).to be false
    end
  end
end
