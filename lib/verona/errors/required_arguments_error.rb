module Verona::Errors
  class RequiredArgumentsError < StandardError
    VALIDATION_MESSAGE = {
        presence: 'must be present'
    }.freeze

    VALIDATION_TYPES = VALIDATION_MESSAGE.keys.freeze

    attr_reader :arguments
    attr_reader :validation

    def initialize(arguments, validation)
      @arguments = arguments
      @validation = validation
    end

    def message
      return "Arguments error" unless arguments
      "Arguments #{arguments.join(', ')} #{VALIDATION_MESSAGE[validation]}".strip
    end
  end
end
