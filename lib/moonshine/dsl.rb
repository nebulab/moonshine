module Moonshine
  module DSL
    def self.included(base)
      base.send :extend, ClassMethods
    end

    module ClassMethods
      attr_accessor :default_subject, :default_chain

      def subject(subject)
        @default_subject = subject
      end

      def param(name, **options, &block)
        @default_chain ||= []
        options[:transform_class] ||= self
        @default_chain << { name: name, options: options, block: block }
      end
    end
  end
end

