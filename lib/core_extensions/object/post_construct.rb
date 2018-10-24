# frozen_string_literal: true

module CoreExtensions
  module Object
    module PostConstruct
      class << self
        alias _new new

        def new(*args)
          new_instance = self.class.new(*args)
          new_instance.send(:post_construct)
          new_instance
        end

        private

        attr_accessor :post_construct
      end

      ::Object.include self
    end
  end
end
