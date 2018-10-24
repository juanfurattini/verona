# frozen_string_literal: true

module Verona
  module Hooks
    def self.included(klass)
      class << klass
        alias_method :__new, :new

        define_method :new do |*args, &block|
          send(before_init_hook) if perform_hook?(before_init_hook, self)
          __new(*args, &block).tap do |instance|
            instance.send(after_init_hook) if perform_hook?(after_init_hook, instance)
          end
        end

        private

        attr_accessor :before_init_hook, :after_init_hook

        def after_initialize(method)
          send(:after_init_hook=, method)
        end

        def before_initialize(method)
          send(:before_init_hook=, method)
        end

        def perform_hook?(hook, target)
          hook.present? && target.respond_to?(hook, true)
        end
      end
      @before_init_hook = nil
      @after_init_hook = nil
    end
  end
end
