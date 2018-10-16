require 'logger'

# Logging support
module Verona
  module Logging
    # Get the logger instance
    #
    # @return [Logger]
    def logger
      Verona.logger
    end
  end
end
