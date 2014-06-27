module Moonshine
  class Base
    attr_reader :chain
    attr_accessor :params, :subject

    def initialize(params, subject = nil)
      @subject = subject
      @params = params
      @chain = []
    end

    def add_filter_to_chain(name, **options, &block)
      @chain << Moonshine::Filter.new(name, options, &block)
    end

    def run
      chain.inject(subject) do |subject, filter|
        filter.params = params
        subject = filter.execute(subject)
      end
    end
  end
end

