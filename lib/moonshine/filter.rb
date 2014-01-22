module Moonshine
  class Filter

    def self.define_on(klass, filter_name, scope, transform: nil, default: nil)
      new(klass, filter_name, scope, transform: transform, default: default).define
    end

    attr_accessor :klass, :name, :scope, :transform, :default

    def initialize(klass, name, scope, transform: nil, default: nil)
      @klass = klass
      @name = name
      @scope = scope
      @transform = transform
      @default = default
    end

    def define
      filter = self
      @klass.send :define_method, name do |value|
        subject.send(filter.scope, filter.set_value(self, value))
      end
    end

    def set_value instance, value
      set_trasform(instance, set_default(value))
    end

    private

    def set_default value
      value || default
    end

    def set_trasform instance, value
      instance.send(transform, value) if transform
      value
    end
  end
end
