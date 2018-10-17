module Verona
  module Utils
    def self.stringify_keys!(object)
      case object
      when Array
        object.map! { |element| stringify_keys!(element) }
      when Hash
        object.keys.each { |key| object[key.to_s] = stringify_keys!(object.delete(key)) }
      else
        # nothing
      end
      object
    end

    def self.present?(object)
      object.to_s.empty?
    end

    def self.not_present?(object)
      !present?(object)
    end
  end
end
