class BaseService
  attr_reader :errors, :data

  def initialize
    @errors = []
  end

  def success?
    @errors.empty?
  end

  def add_error(error)
    if error.is_a?(StandardError)
      @errors << error
    else
      @errors << StandardError.new(error.to_s)
    end
  end

  def error_messages
    @errors.map { |e| e.message }
  end
end
