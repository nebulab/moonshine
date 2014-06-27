module Moonshine
  class Base
    attr_reader :chain
    attr_accessor :params, :subject

    include DSL

    def initialize(params, subject = nil)
      @subject = subject || self.class.default_subject.call
      @params = params
      @chain = []
      if self.class.default_chain
        self.class.default_chain.each do |params|
          add_filter_to_chain(params[:name], params[:options], &params[:block])
        end
      end
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

