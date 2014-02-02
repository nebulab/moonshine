module Moonshine
  class Filter

    attr_accessor :name, :method_name, :transform, :default, :as_boolean

    def initialize(name, method_name: nil, transform: nil, default: nil, as_boolean: nil, &block)
      @name = name
      @method_name = method_name || block
      @transform = transform
      @default = default
      @as_boolean = as_boolean
    end

    def execute(klass)
      unless as_boolean
         args = set_transform(klass, set_default(klass.filters[name]))
      end
      return method_call(klass, args) if klass.filters[name] || default
      klass.subject
    end

    private

    def method_call(klass, *args)
      if method_name.is_a? Proc
        method_name.call(klass, *args)
      else
        klass.subject.send(method_name, *args)
      end
    end

    def set_default value
      value || default
    end

    def set_transform klass, value
      return klass.send(transform, value) if transform
      value
    end
  end
end
