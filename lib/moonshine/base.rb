module Moonshine
  class Base

    attr_accessor :filters, :subject
    attr_reader :chain

    def initialize(filters, subject = nil)
      @filters = filters
      @subject = subject || default_subject
      @chain = @subject.clone
    end

    def run
      filters.each do |method, value|
        send(method, value)
      end
      chain
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
