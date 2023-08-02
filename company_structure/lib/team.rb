module CompanyStructure
  class Team < ActiveRecord::Base
    self.table_name = 'teams'
  end
end
