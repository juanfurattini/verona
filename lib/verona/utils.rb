module Verona
  module Utils
    def self.stringify_keys!(object)
      case object
      when Array
        object.map! { |element| stringify_keys!(element) }
      when Hash
        object.keys.each do |key|
          value = object[key]
          object[key] = stringify_keys!(value)
          object[key.to_s] = object.delete(key)
        end
      else
        # nothing
      end
      object
    end
  end
end
