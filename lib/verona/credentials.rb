module Verona
  class Credentials
    attr_reader :client_id, :client_secret, :access_token, :refresh_token

    # Initializes the credentials.
    #
    # @return [Verona::Credentials]
    def initialize(credentials_path)
      @credentials_path = credentials_path
    end

    # Load credentials from file.
    #
    # @return [Verona::Credentials]
    #
    # @raise [Verona::Errors::CredentialsError] The supplied credentials file path is not valid
    def load!
      raise Verona::Errors::CredentialsError, 'Supplied credentials file path is not valid' unless File.file?(credentials_path)
      credentials_hash = JSON.parse(File.read(credentials_path))
      set_attributes(credentials_hash)
    end

    # Updates in place the credentials and updates the credentials file.
    #
    # @return [Verona::Credentials]
    def update!(updated_values = {})
      return self if updated_values.empty?
      Verona::Utils.stringify_keys!(updated_values)
      updated_attributes = to_hash.merge(updated_values)
      return self if to_hash == updated_attributes
      set_attributes(updated_attributes)
      persist_credentials!
      self
    end

    # Converts the receipt to hash.
    #
    # @return [Hash]
    def to_hash
      {
          client_id: client_id,
          client_secret: client_secret,
          access_token: access_token,
          refresh_token: refresh_token
      }
    end

    alias_method :to_h, :to_hash

    # Converts the receipt to json.
    #
    # @return [String]
    def to_json
      to_hash.to_json
    end

    private
    attr_reader :credentials_path

    def persist_credentials!
      File.open(credentials_path, 'w') { |f| f.write(to_json) }
    end

    def set_attributes(credentials_hash = {})
      Verona::Utils.stringify_keys!(credentials_hash)
      @client_id = credentials_hash['client_id']
      @client_secret = credentials_hash['client_secret']
      @access_token = credentials_hash['access_token']
      @refresh_token = credentials_hash['refresh_token']
    end

  end
end