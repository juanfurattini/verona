require 'json'
require 'net/https'
require 'uri'
require 'retriable'
require 'verona/errors'
require 'verona/logging'

module Verona
  class Client
    include Logging
    REFRESH_TOKEN_URL = 'https://accounts.google.com/o/oauth2/token'.freeze
    VERIFY_PURCHASE_URL = 'https://www.googleapis.com/androidpublisher/v3/applications/%{package}/purchases/products/%{product_id}/tokens/%{purchase_token}'.freeze
    RETRIABLE_ERRORS = [Verona::ServerError, Verona::RateLimitError, Verona::TransmissionError].freeze

    # Initializes the client.
    #
    # @param [String] package: the package of the product
    # @param [String] product_id: the product identifier
    # @param [String] purchase_token: the token of the product purchase
    # @param [String] credentials_path: the path for the credentials json file
    # @param [Hash] options: a hash with custom options
    #
    # @return [Verona::Client]
    #
    # @raise [Verona::CredentialsError] The credentials file path was not supplied or is not valid
    def initialize(package, product_id, purchase_token, credentials_path, options = {})
      @package = package
      @product_id = product_id
      @purchase_token = purchase_token
      @credentials_path = credentials_path
      @options = options
      @credentials = load_credentials
    end

    # Executes the purchase verification process.
    #
    # @return [Verona::Receipt]
    #
    # @raise [Verona::ServerError] An error occurred on the server and the request can be retried
    # @raise [Verona::ClientError] The request is invalid and should not be retried without modification
    # @raise [Verona::AuthorizationError] Authorization is required
    def verify!
      begin
        Retriable.retriable(tries: 2, on: RETRIABLE_ERRORS, base_interval: 1, multiplier: 2) do
          Retriable.retriable(tries: 2, on: Verona::AuthorizationError, on_retry: proc { |*| renew_access_token }) do
            receipt_attributes = validate_purchase
            Verona::Receipt.new(receipt_attributes)
          end
        end
      end
    end

    alias_method :validate!, :verify!

    private
    attr_reader :package, :product_id, :purchase_token, :credentials_path, :options, :credentials

    def load_credentials
      raise CredentialsError, 'Path to credentials file must be present' unless credentials_path
      raise CredentialsError, 'Supplied credentials file path is not valid' unless File.file?(filename)
      JSON.parse(File.read(credentials_path))
    end

    def validate_purchase
      url = generate_validate_url
      logger.debug { sprintf('Sending HTTP %s', url) }
      uri = URI(generate_validate_url)
      params = { access_token: credentials['access_token'] }
      uri.query = URI.encode_www_form(params)
      response = Net::HTTP.get_response(uri)
      process_response(response)
    end

    def generate_validate_url
      VERIFY_PURCHASE_URL % { package: package, product_id: product_id, purchase_token: purchase_token }
    end

    def renew_access_token
      new_token_info = refresh_access_token
      credentials['access_token'] = new_token_info['access_token']
      File.open(credentials_path, 'w') { |f| f.write(credentials.to_json) }
    end

    def refresh_access_token
      logger.debug { sprintf('Sending HTTP %s', REFRESH_TOKEN_URL) }
      uri = URI(REFRESH_TOKEN_URL)
      post_params = {
          grant_type: 'refresh_token',
          client_id: credentials[:client_id],
          client_secret: credentials[:client_secret],
          refresh_token: credentials[:refresh_token] }
      response = Net::HTTP.post_form(uri, post_params)
      process_response(response)
    end

    def process_response(response)
      check_status(response)
      JSON.parse(response.body)
    end

    def check_status(response)
      status, header, body = response.status.to_i, response.header, response.body
      case status
      when 200...300
        nil
      when 301, 302, 303, 307
        message ||= sprintf('Redirect to %s', header['Location'])
        raise Verona::RedirectError.new(message, status_code: status, header: header, body: body)
      when 401
        message ||= 'Unauthorized'
        raise Verona::AuthorizationError.new(message, status_code: status, header: header, body: body)
      when 429
        message ||= 'Rate limit exceeded'
        raise Verona::RateLimitError.new(message, status_code: status, header: header, body: body)
      when 304, 400, 402...500
        message ||= 'Invalid request'
        raise Verona::ClientError.new(message, status_code: status, header: header, body: body)
      when 500...600
        message ||= 'Server error'
        raise Verona::ServerError.new(message, status_code: status, header: header, body: body)
      else
        logger.warn(sprintf('Encountered unexpected status code %s', status))
        message ||= 'Unknown error'
        raise Verona::TransmissionError.new(message, status_code: status, header: header, body: body)
      end
    end
  end
end
