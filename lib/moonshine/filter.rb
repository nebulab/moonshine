module Moonshine
  class Filter

    attr_accessor :name, :params, :options

    def initialize(name, **options, &block)
      @name = name
      options[:call] ||= block || name
      @options = options
    end

    def execute(subject)
      return subject unless to_execute?
      if options[:as_boolean]
        subject.send(options[:call])
      else
        if options[:call].is_a? Proc
          options[:call].call(subject, args)
        else
          subject.send(options[:call], args)
        end
      end
    end

    def to_execute?
      !!default
    end

    private

    def args
      transform(default)
    end

    def default
      params[name] || options[:default]
    end

    def transform(params)
      return params unless options[:transform]
      options[:transform_class].send(options[:transform], params)
    end
  end
end
