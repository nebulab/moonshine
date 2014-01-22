require 'moonshine'
require 'minitest/unit'
require 'mocha/mini_test'
require 'minitest/autorun'
require 'minitest/pride'
require 'coveralls'

# Code coverage
Coveralls.wear!

class MiniTest::Spec
  before :each do
    ::MockSubject = Class.new
    ::MockDefaultSubject = Class.new do
      def scope_method value
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
