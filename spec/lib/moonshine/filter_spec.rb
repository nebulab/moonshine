require 'spec_helper'

describe Moonshine::Filter do
  before(:each) do
    default_subject = mock('default_subject')
    @chain_builder = Class.new(Moonshine::Base) do
      default_subject default_subject
      filter :name, :scope
    end
  end

  after(:each) do
    @chain_builder.class_variable_set(:@@default_subject, nil)
    @chain_builder.class_variable_set(:@@default_chain, [])
    @chain_builder, @default_subject = nil
  end

  describe '#execute' do
    let(:filter) { Moonshine::Filter.new(:filter, :filter) }
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
