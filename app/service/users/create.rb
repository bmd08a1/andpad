module Users
  class Create < BaseService
    def initialize(email:, password:, first_name:, last_name:, company_id:)
      super()
      @email = email
      @password = password
      @first_name = first_name
      @last_name = last_name
      @company_id = company_id
    end

    def call
      ActiveRecord::Base.transaction do
        user_id = SecureRandom.uuid
        @data = User.create!(id: user_id, email: @email, first_name: @first_name, last_name: @last_name,
                             company_id: @company_id)
        Authentication::Account.create!(user_id: user_id, password: @password)
      end
    rescue ActiveRecord::ActiveRecordError => e
      add_error(e)
    end
  end
end
