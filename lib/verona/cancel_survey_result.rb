module Verona
  class CancelSurveyResult
    CANCEL_SURVEY_REASONS = {
      other: 0,
      dont_use_the_service: 1,
      technical_issues: 2,
      cost_related_reasons: 3,
      found_a_better_app: 4
    }.freeze

    # The cancellation reason the user chose in the survey. Possible values are:
    # 0. Other
    # 1. I don't use this service enough
    # 2. Technical issues
    # 3. Cost-related reasons
    # 4. I found a better app
    # Type: integer
    attr_reader :cancel_survey_reason

    # The customized input cancel reason from the user. Only present when cancelReason is 0.
    attr_reader :user_input_cancel_reason

    # Initializes the subscription.
    #
    # @param [Hash] attributes: the attributes to fill object data
    #
    # @return [Verona::Subscription]
    def initialize(attributes = {})
      @cancel_survey_reason = attributes.dig('cancelSurveyReason')
      @user_input_cancel_reason = attributes.dig('userInputCancelReason')
    end

    # Converts the subscription to hash.
    #
    # @return [Hash]
    def to_hash
      {
        cancel_survey_reason: @cancel_survey_reason,
        user_input_cancel_reason: @user_input_cancel_reason
      }
    end

    alias to_h to_hash

    # Converts the subscription to json.
    #
    # @return [String]
    def to_json
      to_hash.to_json
    end
  end
end
