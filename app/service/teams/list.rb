module Teams
  class List < BaseService
    def initialize(current_user:)
      super()
      @current_user = current_user
    end

    def call
      sql = <<-SQL
        SELECT users.first_name, users.last_name, teams.name, teams.id
        FROM users JOIN teams ON users.id = teams.manager_id
        WHERE users.company_id = '#{@current_user.company_id}'
      SQL

      @data = ActiveRecord::Base.connection.execute(sql).map do |datum|
        {
          manager_first_name: datum['first_name'],
          manager_last_name: datum['last_name'],
          team_name: datum['name'],
          team_id: datum['id']
        }
      end
    rescue StandardError => e
      add_error(e)
    end
  end
end
