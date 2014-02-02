module Moonshine
  class Base

    attr_accessor :params
    attr_reader :chain, :subject

    def initialize(params, subject = nil)
      @params = params
      @subject = subject || self.class.default_subject
      @chain = self.class.default_chain || []
    end

    def add(param)
      @chain << param
    end

    def run
      chain.each { |param| @subject = param.execute(self) }
      @subject
    end

    class << self

      attr_accessor :default_subject, :default_chain

      def subject(subject)
        self.default_subject = subject
      end

      def param(name, call: nil, **options, &block)
        self.default_chain ||= []
        self.default_chain << Moonshine::Filter.new(name, method_name: (call || name), **options, &block)
      end
    end
  end
end
