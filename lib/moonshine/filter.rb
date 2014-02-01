module Moonshine
  class Filter

    attr_accessor :name, :scope, :transform, :default, :as_boolean

    def initialize(name, scope: nil, transform: nil, default: nil, as_boolean: nil)
      @name = name
      @scope = scope
      @transform = transform
      @default = default
      @as_boolean = as_boolean
    end

    def execute(klass)
      if klass.filters[name] || default
        if as_boolean
          if klass.filters[name]
            return klass.subject.send(scope)
          else
            return klass.subject.send(scope) if default
          end
        else
          return klass.subject.send(scope, set_transform(klass, set_default(klass.filters[name])))
        end
      end
      klass.subject
    end

    private

    def set_default value
      value || default
    end

    def set_transform klass, value
      return klass.send(transform, value) if transform
      value
    end
  end
end
