require 'test_helper'

describe Moonshine::Filter do
  before(:each) do
    default_subject = mock('default_subject')
    @chain_builder = Class.new(Moonshine::Base) do
      subject default_subject
      param :name, call: :scope
      param :block do |subject, value|
        subject.some_method(value)
      end
    end
  end

  describe '#execute' do
    let(:filter) { Moonshine::Filter.new(:filter, method_name: :filter) }
    let(:chain_builder_instance) { @chain_builder.new({ filter: 1 }) }

    it 'sends scope to klass' do
      chain_builder_instance.subject.expects(:filter).with(1)
      filter.execute(chain_builder_instance)
    end

    it 'return subject when default and value are nil' do
      filter.default = nil
      chain_builder_instance.filters = {}
      filter.execute(chain_builder_instance).must_equal chain_builder_instance.subject
    end

    describe 'when block is given' do
      it 'calls block' do
        block = Proc.new { |subject, value| subject.some_method(value) }
        filter = Moonshine::Filter.new(:filter, &block)
        chain_builder_instance = @chain_builder.new({ filter: 1 })
        filter.method_name.expects(:call)
        filter.execute(chain_builder_instance)
      end
    end

    describe 'options' do
      describe 'transform' do
        it 'changes value with transform method from klass' do
          filter.transform = :transform_method
          chain_builder_instance.subject.stubs(:filter)
          chain_builder_instance.expects(:transform_method).with(1)
          filter.execute(chain_builder_instance)
        end
      end

      describe 'default' do
        it 'uses default value if filter is nil' do
          filter.default = 2
          chain_builder_instance.filters = {}
          chain_builder_instance.subject.expects(:filter).with(2)
          filter.execute(chain_builder_instance)
        end

        it 'not use default value if filter is not nil' do
          filter.default = 2
          chain_builder_instance.filters = { filter: 1 }
          chain_builder_instance.subject.expects(:filter).with(1)
          filter.execute(chain_builder_instance)
        end

        it 'not sends filter if default and value are nil' do
          filter.default = nil
          chain_builder_instance.filters = {}
          chain_builder_instance.subject.expects(:filter).never
          filter.execute(chain_builder_instance)
        end
      end

      describe 'as_boolean' do
        it 'sends method without value when true' do
          filter.as_boolean = true
          chain_builder_instance.filters = { filter: true }
          chain_builder_instance.subject.expects(:filter)
          filter.execute(chain_builder_instance)
        end

        it 'sends method without value when false' do
          filter.as_boolean = true
          chain_builder_instance.filters = { filter: false }
          chain_builder_instance.subject.expects(:filter).never
          filter.execute(chain_builder_instance)
        end
      end
    end
  end

end
