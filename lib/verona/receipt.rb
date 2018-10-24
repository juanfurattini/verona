# frozen_string_literal: true

module Verona
  class Receipt
    PURCHASE_STATES = {
      purchased: 0,
      cancelled: 1
    }.freeze

    CONSUMPTION_STATES = {
      yet_to_be_consumed: 0,
      consumed: 1
    }.freeze

    PURCHASE_TYPES = {
      test: 0,
      promo: 1
    }.freeze

    ## Static initialization:
    ##
    ## Dynamic method generations:
    ##
    ## Defining dynamically each state check method (your_state?)
    # that checks if the receipt has its corresponding state equal to
    # the corresponding states hash
    { PURCHASE_STATES: :purchase_state,
      CONSUMPTION_STATES: :consumption_state,
      PURCHASE_TYPES: :purchase_type }.each_pair do |states_group, attribute|
      const_get(states_group).each_pair do |state_name, state_value|
        define_method "#{state_name}?" do
          state_value == send(attribute)
        end
      end
    end

    # For detailed explanations on these keys/values, see
    # https://developers.google.com/android-publisher/api-ref/purchases/products

    # This kind represents an inappPurchase object in the androidpublisher service.
    # Type: string
    attr_reader :kind

    # The time the product was purchased, in milliseconds since the epoch (Jan 1, 1970).
    # Type: long
    attr_reader :purchase_time_millis

    # The purchase state of the order. Possible values are:
    # 0. Purchased
    # 1. Canceled
    # Type: integer
    attr_reader :purchase_state

    # The consumption state of the inapp product. Possible values are:
    # 0. Yet to be consumed
    # 1. Consumed
    # Type: integer
    attr_reader :consumption_state

    # A developer-specified string that contains supplemental information about an order.
    # Type: string
    attr_reader :developer_payload

    # The order id associated with the purchase of the inapp product.
    # Type: string
    attr_reader :order_id

    # The type of purchase of the inapp product. This field
    # is only set if this purchase was not made using
    # the standard in-app billing flow. Possible values are:
    # 0. Test (i.e. purchased from a license testing account)
    # 1. Promo (i.e. purchased using a promo code)
    # Check: https://developer.android.com/google/play/billing/billing_testing.html
    # Check: https://developer.android.com/google/play/billing/billing_promotions.html
    # Type: integer
    attr_reader :purchase_type

    # Initializes the receipt.
    #
    # @param [Hash] attributes: the attributes to fill object data
    #
    # @return [Verona::Receipt]
    def initialize(attributes = {})
      @kind = attributes['kind']
      @purchase_time_millis = attributes['purchaseTimeMillis']
      @purchase_state = attributes['purchaseState']
      @consumption_state = attributes['consumptionState']
      @developer_payload = attributes['developerPayload']
      @order_id = attributes['orderId']
      @purchase_type = attributes['purchaseType']
    end

    def valid?
      # methods are generated dynamically
      # Check Static initialization / Dynamic method generations
      purchased? && consumed?
    end

    # Converts the receipt to hash.
    #
    # @return [Hash]
    def to_hash
      {
        kind: @kind,
        purchase_time_millis: @purchase_time_millis,
        purchase_state: @purchase_state,
        consumption_state: @consumption_state,
        developer_payload: @developer_payload,
        order_id: @order_id,
        purchase_type: @purchase_type
      }
    end

    alias to_h to_hash

    # Converts the receipt to json.
    #
    # @return [String]
    def to_json
      to_hash.to_json
    end

    class << self
      # Executes the purchase verification process.
      #
      # @param [String] package: the package of the product
      # @param [String] element_id: the product identifier
      # @param [String] purchase_token: the token of the product purchase
      # @param [Hash] options: a hash with custom options
      #
      # @return [Verona::Receipt] if verify process succeed
      #   or [Boolean] false if verify process fails
      def verify(package, element_id, purchase_token, options = {})
        verify!(package, element_id, purchase_token, options)
      rescue Verona::Errors::CredentialsError, Verona::Errors::VerificationError
        false
      end

      # Executes the purchase verification process.
      #
      # @param [String] package: the package of the product
      # @param [String] element_id: the product identifier
      # @param [String] purchase_token: the token of the product purchase
      # @param [Hash] options: a hash with custom options
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
      def verify!(package, element_id, purchase_token, options = {})
        Client.new(package, element_id, purchase_token, normalize_options(options)).verify!
      end

      alias validate verify
      alias validate! verify!

      protected

      def normalize_options(options = {})
        (options || {}).merge!(static_options)
      end

      def static_options
        { validation_type: :product }
      end
    end
  end
end
