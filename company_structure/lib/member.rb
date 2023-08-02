module CompanyStructure
  class Member < ActiveRecord::Base
    self.table_name = 'members'

    belongs_to :team
  end
end
