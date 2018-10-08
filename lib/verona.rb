require 'verona/version'
require 'verona/errors'
require 'verona/client'
require 'verona/receipt'
require 'logger'

module Verona
  private_constant :Client

  # @!attribute [rw] logger
  # @return [Logger] The logger.
  def self.logger
    @logger ||= rails_logger || default_logger
  end

  class << self
    attr_writer :logger
  end

  private

  # Create and configure a logger
  # @return [Logger]
  def self.default_logger
    logger = Logger.new($stdout)
    logger.level = Logger::WARN
    logger
  end

  # Check to see if client is being used in a Rails environment and get the logger if present.
  # Setting the ENV variable 'GOOGLE_API_USE_RAILS_LOGGER' to false will force the client
  # to use its own logger.
  #
  # @return [Logger]
  def self.rails_logger
    if 'true' == ENV.fetch('GOOGLE_API_USE_RAILS_LOGGER', 'true') &&
        defined?(::Rails) &&
        ::Rails.respond_to?(:logger) &&
        !::Rails.logger.nil?
      ::Rails.logger
    else
      nil
    end
  end
end
