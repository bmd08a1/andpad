module Companies
  class Create < ::BaseService
    def initialize(name:, owner:)
      super()
      @name = name
      @owner_attr = owner
    end

    def call
      ActiveRecord::Base.transaction do
        @company_id = SecureRandom.uuid

        @owner_attr.merge!(company_id: @company_id)
        owner = create_owner

        @data = Company.create!(id: @company_id, name: @name, owner_id: owner.id)
      end
    rescue StandardError => e
      add_error(e)
    end

    private

    def create_owner
      service = Users::Create.new(**@owner_attr.except(:password_confirmation))
      service.call

      if service.success?
        return service.data
      else
        raise StandardError.new('cannot_create_owner')
      end
    end
  end
end
