module Moonshine
  class Filter

    attr_accessor :name, :method_name, :options, :klass

    def initialize(name, method_name: nil, **options, &block)
      @name = name
      @method_name = block || method_name
      @options = options
    end

    def execute(klass)
      @klass = klass
      return method_call if klass.params[name] || options[:default]
      klass.subject
    end

    private

    def method_call
      if options[:as_boolean]
        klass.subject.send(method_name)
      else
        if method_name.is_a? Proc
          method_name.call(klass.subject, args)
        else
          klass.subject.send(method_name, args)
        end
      end
    end

    def args
      set_transform(set_default(klass.params[name]))
    end

    def set_default value
      value || options[:default]
    end

    def set_transform value
      return klass.send(options[:transform], value) if options[:transform]
      value
    end
  end
end
