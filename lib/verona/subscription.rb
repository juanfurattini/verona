# frozen_string_literal: true

module Verona
  class Subscription
    PAYMENT_STATES = {
      payment_pending: 0,
      payment_received: 1,
      free_trial: 2
    }.freeze

    CANCEL_REASONS = {
      canceled_by_user: 0,
      canceled_by_system: 1,
      replaced: 2,
      canceled_by_developer: 3
    }.freeze

    PURCHASE_TYPES = {
      test: 0
    }.freeze

    ## Static initialization:
    ##
    ## Dynamic method generations:
    ##
    ## Defining dynamically each state check method (your_state?)
    # that checks if the subscription has its corresponding state equal to
    # the corresponding states hash
    { PAYMENT_STATES: :payment_state,
      CANCEL_REASONS: :cancel_reason,
      PURCHASE_TYPES: :purchase_type }.each_pair do |states_group, attribute|
      const_get(states_group).each_pair do |state_name, state_value|
        define_method "#{state_name}?" do
          state_value == send(attribute)
        end
      end
    end

    # For detailed explanations on these keys/values, see
    # https://developers.google.com/android-publisher/api-ref/purchases/subscriptions

    # This kind represents an subscriptionPurchase object in the androidpublisher service.
    # Type: string
    attr_reader :kind

    # Time at which the subscription was granted, in milliseconds since the Epoch.
    # Type: long
    attr_reader :start_time_millis

    # Time at which the subscription will expire, in milliseconds since the Epoch.
    # Type: long
    attr_reader :expiry_time_millis

    # Whether the subscription will automatically be renewed when it reaches its current expiry time.
    # Type: boolean
    attr_reader :auto_renewing

    # ISO 4217 currency code for the subscription price. For example, if the price is specified
    # in British pounds sterling, price_currency_code is "GBP".
    # Check: http://en.wikipedia.org/wiki/ISO_4217#Active_codes
    # Type: string
    attr_reader :price_currency_code

    # Price of the subscription, not including tax. Price is expressed in micro-units,
    # where 1,000,000 micro-units represents one unit of the currency. For example,
    # if the subscription price is €1.99, price_amount_micros is 1990000.
    # Type: long
    attr_reader :price_amount_micros

    # ISO 3166-1 alpha-2 billing country/region code of the user at the time the subscription was granted.
    # Check: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2#Current_codes
    # Type: string
    attr_reader :country_code

    # A developer-specified string that contains supplemental information about an order.
    # Type: string
    attr_reader :developer_payload

    # The payment state of the subscription. Possible values are:
    # 0. Payment pending
    # 1. Payment received
    # 2. Free trial
    # Type: integer
    attr_reader :payment_state

    # The reason why a subscription was canceled or is not auto-renewing. Possible values are:
    # 0. User canceled the subscription
    # 1. Subscription was canceled by the system, for example because of a billing problem
    # 2. Subscription was replaced with a new subscription
    # 3. Subscription was canceled by the developer
    # Type: integer
    attr_reader :cancel_reason

    # The time at which the subscription was canceled by the user, in milliseconds since the epoch.
    # Only present if cancelReason is 0.
    # Type: long
    attr_reader :user_cancellation_time_millis

    # Information provided by the user when they complete the subscription
    # cancellation flow (cancellation reason survey).
    # Type: nested object (Verona::CancelSurveyResult)
    attr_reader :cancel_survey_result

    # The order id of the latest recurring order associated with the purchase of the subscription.
    # Type: string
    attr_reader :order_id

    # The purchase token of the originating purchase if this subscription is one of the following:
    # · Re-signup of a canceled but non-lapsed subscription
    # · Upgrade/downgrade from a previous subscription
    # For example, suppose a user originally signs up and you receive purchase token X, then
    # the user cancels and goes through the resignup flow (before their subscription lapses)
    # and you receive purchase token Y, and finally the user upgrades their subscription and you
    # receive purchase token Z. If you call this API with purchase token Z,
    # this field will be set to Y. If you call this API with purchase token Y,
    # this field will be set to X. If you call this API with purchase token X,
    # this field will not be set.
    # Type: string
    attr_reader :linked_purchase_token

    # The type of purchase of the subscription. This field is only set if this purchase was not
    # made using the standard in-app billing flow. Possible values are:
    # 0. Test (i.e. purchased from a license testing account)
    # Check: https://developer.android.com/google/play/billing/billing_testing.html
    # Type: integer
    attr_reader :purchase_type

    # The profile name of the user when the subscription was purchased.
    # Only present for purchases made with 'Subscribe with Google'.
    # Check: https://g.co/newsinitiative/subscribe
    # Type: string
    attr_reader :profile_name

    # The email address of the user when the subscription was purchased.
    # Only present for purchases made with 'Subscribe with Google'.
    # Check: https://g.co/newsinitiative/subscribe
    # Type: string
    attr_reader :email_address

    # The given name of the user when the subscription was purchased.
    # Only present for purchases made with 'Subscribe with Google'.
    # Check: https://g.co/newsinitiative/subscribe
    # Type: string
    attr_reader :given_name

    # The family name of the user when the subscription was purchased.
    # Only present for purchases made with 'Subscribe with Google'.
    # Check: https://g.co/newsinitiative/subscribe
    # Type: string
    attr_reader :family_name

    # The profile id of the user when the subscription was purchased.
    # Only present for purchases made with 'Subscribe with Google'.
    # Check: https://g.co/newsinitiative/subscribe
    # Type: string
    attr_reader :profile_id

    # Initializes the subscription.
    #
    # @param [Hash] attributes: the attributes to fill object data
    #
    # @return [Verona::Subscription]
    def initialize(attributes = {})
      @kind = attributes.dig('kind')
      @start_time_millis = attributes.dig('startTimeMillis')
      @expiry_time_millis = attributes.dig('expiryTimeMillis')
      @auto_renewing = attributes.dig('autoRenewing')
      @price_currency_code = attributes.dig('priceCurrencyCode')
      @price_amount_micros = attributes.dig('priceAmountMicros')
      @country_code = attributes.dig('countryCode')
      @developer_payload = attributes.dig('developerPayload')
      @payment_state = attributes.dig('paymentState')
      @cancel_reason = attributes.dig('cancelReason')
      @user_cancellation_time_millis = attributes.dig('userCancellationTimeMillis')
      @cancel_survey_result = build_cancel_survey_result(attributes)
      @order_id = attributes.dig('orderId')
      @linked_purchase_token = attributes.dig('linkedPurchaseToken')
      @purchase_type = attributes.dig('purchaseType')
      @profile_name = attributes.dig('profileName')
      @email_address = attributes.dig('emailAddress')
      @given_name = attributes.dig('givenName')
      @family_name = attributes.dig('familyName')
      @profile_id = attributes.dig('profileId')
    end

    def build_cancel_survey_result(attributes)
      return unless attributes.key?('cancelSurveyResult')

      Verona::CancelSurveyResult.new(attributes.fetch('cancelSurveyResult', {}))
    end

    def valid?
      # methods are generated dynamically
      # Check Static initialization / Dynamic method generations
      payment_received? && !cancelled?
    end

    def cancelled?
      cancel_reason.present?
    end

    # Converts the subscription to hash.
    #
    # @return [Hash]
    def to_hash
      {
        kind: @kind,
        start_time_millis: @start_time_millis,
        expiry_time_millis: @expiry_time_millis,
        auto_renewing: @auto_renewing,
        price_currency_code: @price_currency_code,
        price_amount_micros: @price_amount_micros,
        country_code: @country_code,
        developer_payload: @developer_payload,
        payment_state: @payment_state,
        cancel_reason: @cancel_reason,
        user_cancellation_time_millis: @user_cancellation_time_millis,
        cancel_survey_result: @cancel_survey_result&.to_hash,
        order_id: @order_id,
        linked_purchase_token: @linked_purchase_token,
        purchase_type: @purchase_type,
        profile_name: @profile_name,
        email_address: @email_address,
        given_name: @given_name,
        family_name: @family_name,
        profile_id: @profile_id
      }
    end

    alias to_h to_hash

    # Converts the subscription to json.
    #
    # @return [String]
    def to_json
      to_hash.to_json
    end

    class << self
      # Executes the purchase verification process.
      #
      # @return [Verona::Subscription] if verify process succeed
      # @return false if verify process fails
      def verify(package, element_id, purchase_token, options = {})
        verify!(package, element_id, purchase_token, options)
      rescue Verona::Errors::CredentialsError, Verona::Errors::VerificationError
        false
      end

      # Executes the purchase verification process.
      #
      # @return [Verona::Subscription]
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
        { validation_type: :subscription }
      end
    end
  end
end
