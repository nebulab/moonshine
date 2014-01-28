module Moonshine
  class Base

    @@default_chain = []
    attr_accessor :filters
    attr_reader :chain, :subject

    def initialize(filters, subject = nil)
      @filters = filters
      @subject = subject || @@default_subject
      @chain = @@default_chain
    end

    def add(filter)
      @chain << filter
    end

    def run
      chain.each { |filter| @subject = filter.execute(self) }
      @subject
    end

    class << self
      def default_subject(klass)
        @@default_subject = klass
      end

      def filter name, scope, transform: nil, default: nil, as_boolean: nil
        @@default_chain << Moonshine::Filter.new(name, scope, transform: transform, default: default, as_boolean: as_boolean)
      end
    end
  end
end
