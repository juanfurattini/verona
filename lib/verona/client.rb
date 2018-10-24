# frozen_string_literal: true

require 'json'
require 'net/https'
require 'uri'
require 'retriable'

module Verona
  class Client
    include Logging
    include Hooks
    REFRESH_TOKEN_URL = 'https://accounts.google.com/o/oauth2/token'
    GOOGLE_APIS_URL = 'https://www.googleapis.com'
    VERIFY_BASE_URL = 'androidpublisher/v3/applications/%<package>s/purchases'
    VERIFY_TYPE_URLS = {
      product: 'products/%<element_id>s/tokens/%<purchase_token>s',
      subscription: 'subscriptions/%<element_id>s/tokens/%<purchase_token>s'
    }.freeze
    RETRIABLE_ERRORS = [
      Verona::Errors::ServerError,
      Verona::Errors::RateLimitError,
      Verona::Errors::TransmissionError
    ].freeze
    UPDATABLE_CREDENTIALS_FIELDS = [:access_token].freeze

    after_initialize :check_preconditions!

    # Initializes the client.
    #
    # @param [String] package: the package of the product
    # @param [String] element_id: the product identifier
    # @param [String] purchase_token: the token of the product purchase
    # @param [Hash] options: a hash with custom options
    #
    # @return [Verona::Client]
    #
    # @raise [Verona::Errors::RequiredArgumentsError] At least one of the required parameters
    #   (package, element_id, purchase_token) were not supplied
    def initialize(package, element_id, purchase_token, options = {})
      @package = package
      @element_id = element_id
      @purchase_token = purchase_token
      @options = options
      @credentials = Verona::Credentials.new
    end

    # Executes the purchase verification process.
    #
    # @return [Verona::Receipt]
    #
    # @raise [Verona::Errors::CredentialsError] The credentials file path was not
    #   supplied or is not valid
    # @raise [Verona::Errors::ServerError] An error occurred on the server and
    #   the request can be retried
    # @raise [Verona::Errors::ClientError] The request is invalid and should not
    #   be retried without modification
    # @raise [Verona::Errors::AuthorizationError] Authorization is required
    # @raise [Verona::Errors::RedirectError] A redirect is required and should not
    #   be retried without modification
    # @raise [Verona::Errors::RateLimitError] A limitation occurred on in message
    #   transport and the request can be retried
    # @raise [Verona::Errors::TransmissionError] A transport error occurred on the
    #   message transport and the request can be retried
    def verify!
      credentials.load!
      Retriable.retriable(tries: 2, on: RETRIABLE_ERRORS, base_interval: 1, multiplier: 2) do
        Retriable.retriable(tries: 2,
                            on: Verona::Errors::AuthorizationError,
                            on_retry: proc { |*| renew_access_token }) do
          receipt_attributes = validate_purchase
          Verona::Receipt.new(receipt_attributes)
        end
      end
    end

    alias validate! verify!

    protected

    def purchase_type
      # must inherit
    end

    private

    attr_reader :package, :element_id, :purchase_token, :options, :credentials

    def check_preconditions!
      logger.debug('check_preconditions!')
      required_fields = %i[package element_id purchase_token]
      not_present = required_fields.select(&:not_present?)
      raise Verona::Errors::RequiredArgumentsError(not_present, :presence) unless not_present.empty?
    end

    def validate_purchase
      url = generate_validation_url
      logger.debug("Sending HTTP #{url}")
      uri = URI(url)
      params = { access_token: credentials.access_token }
      uri.query = URI.encode_www_form(params)
      response = Net::HTTP.get_response(uri)
      process_response(response)
    end

    def generate_validation_url
      format(build_url_string,
             package: package, element_id: element_id, purchase_token: purchase_token)
    end

    def build_url_string
      "#{GOOGLE_APIS_URL}/#{VERIFY_BASE_URL}/#{choose_verify_purchase_url}"
    end

    def choose_verify_purchase_url
      validation_type = options.fetch(:validation_type, nil)
      VERIFY_TYPE_URLS.dig(validation_type)
    end

    def renew_access_token
      new_token_info = refresh_access_token
      filtered_info = new_token_info.select { |key, _| UPDATABLE_CREDENTIALS_FIELDS.include?(key.to_sym) }
      credentials.update!(filtered_info)
    end

    def refresh_access_token
      logger.debug("Sending HTTP #{REFRESH_TOKEN_URL}")
      uri = URI(REFRESH_TOKEN_URL)
      post_params = {
        grant_type: 'refresh_token',
        client_id: credentials.client_id,
        client_secret: credentials.client_secret,
        refresh_token: credentials.refresh_token
      }
      response = Net::HTTP.post_form(uri, post_params)
      process_response(response)
    end

    def process_response(response)
      check_status(response)
      JSON.parse(response.body)
    end

    def check_status(response)
      status = response.code.to_i
      header = response.header
      body = response.body
      case status
      when 200...300
        nil
      when 301, 302, 303, 307
        message = "Redirect to #{header['Location']}"
        raise Verona::Errors::RedirectError.new(
          status_code: status, header: header, body: body
        ), message
      when 401
        message = 'Unauthorized'
        raise Verona::Errors::AuthorizationError.new(
          status_code: status, header: header, body: body
        ), message
      when 429
        message = 'Rate limit exceeded'
        raise Verona::Errors::RateLimitError.new(
          status_code: status, header: header, body: body
        ), message
      when 304, 400, 402...500
        message = 'Invalid request'
        raise Verona::Errors::ClientError.new(
          status_code: status, header: header, body: body
        ), message
      when 500...600
        message = 'Server error'
        raise Verona::Errors::ServerError.new(
          status_code: status, header: header, body: body
        ), message
      else
        logger.warn("Encountered unexpected status code #{status}")
        message = 'Unknown error'
        raise Verona::Errors::TransmissionError.new(
          status_code: status, header: header, body: body
        ), message
      end
    end
  end
end
