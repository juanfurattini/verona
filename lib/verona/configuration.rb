module Verona
  class Configuration
    attr_accessor :use_rails_logger, :credentials_file_path

    def initialize
      @use_rails_logger = false
      @credentials_file_path = '/config/verona/credentials.json'
    end

    def use_rails_logger?
      !!use_rails_logger
    end
  end
end
