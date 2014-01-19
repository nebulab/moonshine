module Moonshine
  class Base

    attr_accessor :filters
    attr_accessor :subject

    def initialize(filters, subject = nil)
      @filters = filters
      @subject = subject || default_subject.new
    end

    class << self
      def subject(klass)
        define_method :default_subject do
          klass
        end
      end
    end
  end
end
