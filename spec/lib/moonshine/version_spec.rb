require 'test_helper'

describe Moonshine::VERSION do

  it 'is 0.0.1.pre' do
    Moonshine::VERSION.must_equal '0.0.1.pre'
  end
end
