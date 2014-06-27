require 'coveralls'

# Code coverage
Coveralls.wear!

require 'moonshine'
require 'minitest/autorun'
require 'mocha/mini_test'
require 'minitest/pride'
require 'support/tale_transform'
require 'support/tale'
require 'support/tale_generator'
require 'support/empty_tale_generator'

class MiniTest::Spec
end
