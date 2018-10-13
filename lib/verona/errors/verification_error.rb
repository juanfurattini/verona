module Verona::Errors
  class VerificationError < StandardError
    attr_reader :status_code
    attr_reader :header
    attr_reader :body

    def initialize(status_code: nil, header: nil, body: nil)
      @status_code = status_code
      @header = header.dup unless header.nil?
      @body = body
    end
  end

  # An error which is raised when there is an unexpected response or other
  # transport error that prevents an operation from succeeding.
  class TransmissionError < VerificationError
  end

  # An exception that is raised if a redirect is required
  class RedirectError < VerificationError
  end

  # A 4xx class HTTP error occurred.
  class ClientError < VerificationError
  end

  # A 4xx class HTTP error occurred.
  class RateLimitError < VerificationError
  end

  # A 403 HTTP error occurred.
  class ProjectNotLinkedError < VerificationError
  end

  # A 401 HTTP error occurred.
  class AuthorizationError < VerificationError
  end

  # A 5xx class HTTP error occurred.
  class ServerError < VerificationError
  end

  # Error class for problems in batch requests.
  class BatchError < VerificationError
  end
end
