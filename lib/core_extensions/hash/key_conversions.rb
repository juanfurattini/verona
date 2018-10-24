# frozen_string_literal: true

module CoreExtensions
  module Hash
    module KeyConversions
      # Converts in place all the keys to string
      #
      # @return [Hash]
      def stringify_keys!
        stringify_keys_impl!(self)
      end

      private

      def stringify_keys_impl!(object)
        case object
        when ::Array
          object.map! { |element| stringify_keys_impl!(element) }
        when ::Hash
          object.keys.each { |key| object[key.to_s] = stringify_keys_impl!(object.delete(key)) }
        else
          # nothing
        end
        object
      end

      ::Hash.include self
    end
  end
end
