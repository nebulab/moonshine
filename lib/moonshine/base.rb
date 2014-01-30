module Moonshine
  class Base

    attr_accessor :filters
    attr_reader :chain, :subject

    def initialize(filters, subject = nil)
      @filters = filters
      @subject = subject || self.class.default_subject
      @chain = self.class.default_chain || []
    end

    def add(filter)
      @chain << filter
    end

    def run
      chain.each { |filter| @subject = filter.execute(self) }
      @subject
    end

    class << self

      attr_accessor :default_subject, :default_chain

      def subject(subject)
        self.default_subject = subject
      end

      def filter name, scope, transform: nil, default: nil, as_boolean: nil
        self.default_chain ||= []
        self.default_chain << Moonshine::Filter.new(name, scope, transform: transform, default: default, as_boolean: as_boolean)
      end
    end
  end
end
