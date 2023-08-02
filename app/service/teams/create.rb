module Teams
  class Create < BaseService
    def initialize(name:, manager_id:)
      @name = name
      @manager_id = manager_id
    end

    def call
    end
  end
end
