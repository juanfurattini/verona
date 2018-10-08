module Verona
  class VerificationError < StandardError
    attr_reader :status_code
    attr_reader :header
    attr_reader :body

    def initialize(err, status_code: nil, header: nil, body: nil)
      @cause = nil

      if err.respond_to?(:backtrace)
        super(err.message)
        @cause = err
      else
        super(err.to_s)
      end
      @status_code = status_code
      @header = header.dup unless header.nil?
      @body = body
    end

    def backtrace
      if @cause
        @cause.backtrace
      else
        super
      end
    end
  end

  # An error which is raised when there is an unexpected response or other
  # transport error that prevents an operation from succeeding.
  class TransmissionError < Error
  end

  # An exception that is raised if a redirect is required
  class RedirectError < Error
  end

  # A 4xx class HTTP error occurred.
  class ClientError < Error
  end

  # A 4xx class HTTP error occurred.
  class RateLimitError < Error
  end

  # A 403 HTTP error occurred.
  class ProjectNotLinkedError < Error
  end

  # A 401 HTTP error occurred.
  class AuthorizationError < Error
  end

  # A 5xx class HTTP error occurred.
  class ServerError < Error
  end

  # Error class for problems in batch requests.
  class BatchError < Error
  end
end
