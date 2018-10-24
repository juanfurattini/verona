# frozen_string_literal: true

module Verona
  class Credentials
    FILE_PATH_NOT_PRESENT = 'Credentials file path was not supplied'
    FILE_PATH_NOT_VALID = 'Supplied credentials file path is not valid'

    attr_reader :client_id, :client_secret, :access_token, :refresh_token

    # Load credentials from file.
    #
    # @return [Verona::Credentials]
    #
    # @raise [Verona::Errors::CredentialsError] The supplied credentials file path is not valid
    def load!
      check_pre_condition!(credentials_path.present?, FILE_PATH_NOT_PRESENT)
      check_pre_condition!(File.file?(credentials_path), FILE_PATH_NOT_VALID)

      credentials_hash = JSON.parse(File.read(credentials_path))
      attributes(credentials_hash)
    end

    # Updates in place the credentials and updates the credentials file.
    #
    # @param [Hash] updated_values: the updated attributes
    #
    # @return [Verona::Credentials]
    def update!(updated_values = {})
      return self if updated_values.empty?

      updated_values.stringify_keys!
      updated_attributes = to_hash.merge!(updated_values)
      return self if to_hash == updated_attributes

      attributes(updated_attributes)
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
      }.stringify_keys!
    end

    alias to_h to_hash

    # Converts the receipt to json.
    #
    # @return [String]
    def to_json
      to_hash.to_json
    end

    private

    def check_pre_condition!(pre_condition, error_message)
      raise Verona::Errors::CredentialsError, error_message unless pre_condition
    end

    def persist_credentials!
      File.open(credentials_path, 'w') { |f| f.write(to_json) }
    end

    def attributes(credentials_hash = {})
      credentials_hash.stringify_keys!

      @client_id = credentials_hash['client_id'] if credentials_hash.key?('client_id')
      @client_secret = credentials_hash['client_secret'] if credentials_hash.key?('client_secret')
      @access_token = credentials_hash['access_token'] if credentials_hash.key?('access_token')
      @refresh_token = credentials_hash['refresh_token'] if credentials_hash.key?('refresh_token')
    end

    def credentials_path
      configuration.credentials_file_path
    end

    def configuration
      Verona.configuration
    end
  end
end
