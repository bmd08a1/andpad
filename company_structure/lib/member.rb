module CompanyStructure
  class Member < ActiveRecord::Base
    self.table_name = 'members'
  end
end
