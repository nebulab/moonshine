module Moonshine
  class Base

    attr_accessor :filters
    attr_accessor :subject

    def initialize(filters, subject = nil)
      @filters = filters
      @subject = subject || default_subject
    end

    def all
      filters.keys.inject(subject) do |obj, method|
        send(method, filters[method])
      end
    end

    class << self
      def subject(klass)
        define_method :default_subject do
          klass
        end
      end

      def filter name, scope, transform: nil, default: nil
        Moonshine::Filter.define_on(self, name, scope, transform: transform, default: default)
      end
    end
  end
end
