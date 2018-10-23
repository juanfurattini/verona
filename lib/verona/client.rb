require 'json'
require 'net/https'
require 'uri'
require 'retriable'

module Verona
  class Client
    include Logging
    REFRESH_TOKEN_URL = 'https://accounts.google.com/o/oauth2/token'.freeze
    VERIFY_PURCHASE_URL = 'https://www.googleapis.com/androidpublisher/v3/applications/%{package}/purchases/products/%{product_id}/tokens/%{purchase_token}'.freeze
    RETRIABLE_ERRORS = [Verona::Errors::ServerError, Verona::Errors::RateLimitError, Verona::Errors::TransmissionError].freeze
    UPDATABLE_CREDENTIALS_FIELDS = [:access_token].freeze

    # Initializes the client.
    #
    # @param [String] package: the package of the product
    # @param [String] product_id: the product identifier
    # @param [String] purchase_token: the token of the product purchase
    # @param [Hash] options: a hash with custom options
    #
    # @return [Verona::Client]
    #
    # @raise [Verona::Errors::RequiredArgumentsError] At least one of the required parameters
    #   (package, product_id, purchase_token) were not supplied
    def initialize(package, product_id, purchase_token, options = {})
      @package = package
      @product_id = product_id
      @purchase_token = purchase_token
      @options = options
      @credentials = Verona::Credentials.new
      check_preconditions!
    end

    # Executes the purchase verification process.
    #
    # @return [Verona::Receipt]
    #
    # @raise [Verona::Errors::CredentialsError] The supplied credentials file path is not valid
    # @raise [Verona::Errors::ServerError] An error occurred on the server and the request can be retried
    # @raise [Verona::Errors::ClientError] The request is invalid and should not be retried without modification
    # @raise [Verona::Errors::AuthorizationError] Authorization is required
    def verify!
      begin
        credentials.load!
        Retriable.retriable(tries: 2, on: RETRIABLE_ERRORS, base_interval: 1, multiplier: 2) do
          Retriable.retriable(tries: 2, on: Verona::Errors::AuthorizationError, on_retry: proc { |*| renew_access_token }) do
            receipt_attributes = validate_purchase
            Verona::Receipt.new(receipt_attributes)
          end
        end
      rescue => e
        # Refactorize this!
      end
    end

    alias validate! verify!

    private

    attr_reader :package, :product_id, :purchase_token, :options, :credentials

    def check_preconditions!
      required_fields = [:package, :product_id, :purchase_token]
      not_present = required_fields.select { |field| Verona.not_present?(field) }
      raise Verona::Errors::RequiredArgumentsError(not_present, :presence) unless not_present.empty?
    end

    def is_field_present?(attribute)
      !send(attribute.to_sym).to_s.empty?
    end

    def validate_purchase
      url = generate_validate_url
      logger.debug { sprintf('Sending HTTP %s', url) }
      uri = URI(generate_validate_url)
      params = { access_token: credentials.access_token }
      uri.query = URI.encode_www_form(params)
      response = Net::HTTP.get_response(uri)
      process_response(response)
    end

    def generate_validate_url
      VERIFY_PURCHASE_URL % { package: package, product_id: product_id, purchase_token: purchase_token }
    end

    def renew_access_token
      new_token_info = refresh_access_token
      filtered_info = new_token_info.select { |key, _| UPDATABLE_CREDENTIALS_FIELDS.include?(key.to_sym) }
      credentials.update!(filtered_info)
    end

    def refresh_access_token
      logger.debug { sprintf('Sending HTTP %s', REFRESH_TOKEN_URL) }
      uri = URI(REFRESH_TOKEN_URL)
      post_params = {
          grant_type: 'refresh_token',
          client_id: credentials.client_id,
          client_secret: credentials.client_secret,
          refresh_token: credentials.refresh_token }
      response = Net::HTTP.post_form(uri, post_params)
      process_response(response)
    end

    def process_response(response)
      check_status(response)
      JSON.parse(response.body)
    end

    def check_status(response)
      status, header, body = response.code.to_i, response.header, response.body
      case status
      when 200...300
        nil
      when 301, 302, 303, 307
        message = sprintf('Redirect to %s', header['Location'])
        raise Verona::Errors::RedirectError.new(status_code: status, header: header, body: body), message
      when 401
        message = 'Unauthorized'
        raise Verona::Errors::AuthorizationError.new(status_code: status, header: header, body: body), message
      when 429
        message = 'Rate limit exceeded'
        raise Verona::Errors::RateLimitError.new(status_code: status, header: header, body: body), message
      when 304, 400, 402...500
        message = 'Invalid request'
        raise Verona::Errors::ClientError.new(status_code: status, header: header, body: body), message
      when 500...600
        message = 'Server error'
        raise Verona::Errors::ServerError.new(status_code: status, header: header, body: body), message
      else
        logger.warn(sprintf('Encountered unexpected status code %s', status))
        message = 'Unknown error'
        raise Verona::Errors::TransmissionError.new(status_code: status, header: header, body: body), message
      end
    end
  end
end
