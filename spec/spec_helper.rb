require 'coveralls'

# Code coverage
Coveralls.wear!

require 'moonshine'
require 'minitest/autorun'
require 'mocha/mini_test'
require 'minitest/pride'

class MiniTest::Spec
  before :each do
    ::MockSubject = Class.new
    ::MockDefaultSubject = Class.new do
      def self.scope_method value
      end
    end
    ::MockChainBuilder = Class.new(Moonshine::Base) do
      subject MockDefaultSubject

      def clean value
      end
    end
  end

  after :each do
    Object.send(:remove_const, 'MockChainBuilder')
    Object.send(:remove_const, 'MockSubject')
    Object.send(:remove_const, 'MockDefaultSubject')
  end
end
