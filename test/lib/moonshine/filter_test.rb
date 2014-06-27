require 'test_helper'

describe Moonshine::Filter do

  let(:tale) { Tale.new }
  let(:filter) { Moonshine::Filter.new(:character) }

  describe '#to_execute?' do
    describe 'when params have a key like filter name' do
      it 'returns true' do
        filter.params = { character: 'a developer' }
        filter.to_execute?.must_equal true
      end
    end

    describe 'when options have a default value' do
      it 'returns true' do
        filter.options[:default] = true
        filter.params = { antagonist: 'a designer'}
        filter.to_execute?.must_equal true
      end
    end

    describe 'when params does not have a key like filter name and does
              not have a default value' do
      it 'returns false' do
        filter.params = { antagonist: 'a designer'}
        filter.to_execute?.must_equal false
      end
    end
  end

  describe '#execute' do
    describe 'when to_execute? return false' do
      it 'returns given subject' do
        filter.params = { antagonist: 'a designer'}
        filter.execute(tale).must_equal tale
      end
    end

    describe 'when to_execute? return true' do

      before do
        filter.params = { character: 'a developer' }
      end

      describe 'and call is a block' do
        it 'calls given block' do
          filter.options[:call] = -> (subject, params){}
          filter.options[:call].expects(:call).with(tale, 'a developer')
          filter.execute(tale)
        end
      end

      it 'sends method to given subject' do
        tale.expects(:character).with('a developer')
        filter.execute(tale)
      end

      it 'returns given subject' do
        filter.execute(tale).must_equal tale
      end

      describe 'options' do
        describe 'transform' do
          before do
            filter.options[:transform_class] = TaleTransform
            filter.options[:transform] = :to_upper
          end

          it 'sends transform method on given transform class' do
            TaleTransform.expects(:to_upper).with('a developer')
            filter.execute(tale)
          end

          it 'sends method to given subject with transformed value' do
            tale.expects(:character).with('A DEVELOPER')
            filter.execute(tale)
          end
        end

        describe 'default' do
          before do
            filter.options[:default] = 'a designer'
          end

          describe 'when params have key like filter name' do
            it 'sends method to given subject with given value' do
              tale.expects(:character).with('a developer')
              filter.execute(tale)
            end
          end

          describe 'when params does not have key like filter name' do
            it 'sends method to given subject with default value' do
              tale.expects(:character).with('a designer')
              filter.params = {}
              filter.execute(tale)
            end
          end
        end

        describe 'as_boolean' do
          before do
            filter.options[:as_boolean] = true
          end

          describe 'when params have key like filter name' do
            describe 'and value is true' do
              it 'sends method to given subject whitout params' do
                tale.expects(:character).with()
                filter.params = { character: true }
                filter.execute(tale)
              end
            end

            describe 'and value is false' do
              it 'do not sends method to given subject' do
                tale.expects(:character).with().never
                filter.params = { character: false }
                filter.execute(tale)
              end
            end
          end

          describe 'when params does not have key like filter name' do
            it 'do not sends method to given subject' do
              tale.expects(:character).with().never
              filter.params = {}
              filter.execute(tale)
            end
          end
        end
      end
    end
  end
end

