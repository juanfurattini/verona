module Verona::Errors
  class RequiredArgumentsError < StandardError
    VALIDATION_MESSAGE = {
        presence: 'must be present'
    }.freeze

    VALIDATION_TYPES = VALIDATION_MESSAGE.keys.freeze

    attr_reader :argument
    attr_reader :validation

    def initialize(argument, validation)
      @argument = argument
      @validation = validation
    end

    def message
      return "Arguments error" unless argument
      "Argument #{argument&.to_s} #{VALIDATION_MESSAGE[validation]}".strip
    end
  end
end
