require 'rails_helper'

describe CompanyStructure::Team, type: :model do
  describe '#add_member' do
    let(:team) { create(:team) }
    let(:member_id) { SecureRandom.uuid }

    context 'member is not in any team' do
      it 'creates a new member record' do
        expect{ team.add_member(member_id) }.to change{ CompanyStructure::Member.where(user_id: member_id).count }
      end
    end

    context 'member is in another team' do
      let!(:member) { create(:member, user_id: member_id, team: other_team) }
      let(:other_team) { create(:team) }

      it 'creates a new member record with new team and remove old member record' do
        team.add_member(member_id)

        expect(CompanyStructure::Member.find_by(id: member.id)).to be nil
        expect(CompanyStructure::Member.where(user_id: member_id).count).to eql(1)
      end
    end

    context 'member is already in current team' do
      let!(:member) { create(:member, user_id: member_id, team: team) }

      it 'keeps current member record' do
        team.add_member(member_id)

        expect(CompanyStructure::Member.find_by(id: member.id)).to be_present
      end
    end
  end

  describe '#remove_member' do
    let!(:member) { create(:member, team: team) }
    let(:team) { create(:team) }

    it 'deletes member record' do
      team.remove_member(member.user_id)

      expect(CompanyStructure::Member.find_by(id: member.id)).to be nil
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:members) }
  end
end
