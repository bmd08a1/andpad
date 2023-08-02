module CompanyStructure
  class Team < ActiveRecord::Base
    self.table_name = 'teams'

    has_many :members

    def add_member(member_id)
      if other_team = Member.find_by(user_id: member_id).team
        other_team.remove_member(member_id)
      end
      members.create(user_id: member_id)
    end

    def remove_member(member_id)
      members.destroy(user_id: member_id)
    end
  end
end
