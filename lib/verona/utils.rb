module Verona
  module Utils
    def self.stringify_keys!(hash)
      hash.keys.each do |key|
        value = hash[key]
        hash[key] = stringify_keys!(value) if value.is_a?(Hash)
        hash[key] = value.map { |e| e.is_a?(Hash) ? stringify_keys!(e) : e } if value.is_a?(Array)
        hash[key.to_s] = hash.delete(key) unless key.is_a?(String)
      end
      hash
    end
  end
end
