require 'test_helper'

describe Moonshine::Base do
  before(:each) do
    @chain_builder = Class.new(Moonshine::Base)
    @default_subject = mock('default_subject')
  end

  describe '.subject' do
    before do
      @chain_builder.default_subject = @default_subject
    end

    it 'sets default subject class attribute' do
      @chain_builder.default_subject.must_equal @default_subject
    end

    describe 'when it is initialized without a subject' do
      it 'sets subject as default subject' do
        @chain_builder.new({}).subject.must_equal @default_subject
      end
    end

    describe 'when it is initialized with a subject' do
      let(:subject){ mock('subject') }

      it 'sets subject as requested' do
        @chain_builder.new({}, subject).subject.must_equal subject
      end
    end
  end

  describe '.when' do
    it 'instantiates a Moonshine::Filter class' do
      Moonshine::Filter.expects(:new).with(:filter_name, scope: :scope, transform: nil, default: nil, as_boolean: nil)
      @chain_builder.when :filter_name, call: :scope
    end

    describe 'when :call is not given' do
      it 'instantiates a Moonshine::Filter class with call same as first param' do
        Moonshine::Filter.expects(:new).with(:filter_name, scope: :filter_name, transform: nil, default: nil, as_boolean: nil)
        @chain_builder.when :filter_name
      end
    end

    it 'adds filter to default_chain' do
      filter =  mock('filter')
      Moonshine::Filter.stubs(:new).returns(filter)
      @chain_builder.when :filter_name, call: :scope
      @chain_builder.default_chain.must_equal [filter]
    end
  end

  describe '#add' do
    it 'adds filter to chain' do
      filter = mock('filter')
      chain_builder_instance = @chain_builder.new({})
      chain_builder_instance.add(filter)
      chain_builder_instance.chain.must_equal [filter]
    end
  end

  describe '#run' do

    it 'run execute on each filter' do
      filter1 = mock('filter1')
      filter1.stubs(:name).returns(:filter1)
      filter2 = mock('filter2')
      filter2.stubs(:name).returns(:filter2)
      filters = [filter1, filter2]
      @chain_builder.default_chain = filters
      chain_builder_instance = @chain_builder.new({ filter1: 1, filter2: 2})
      filter1.expects(:execute).with(chain_builder_instance)
      filter2.expects(:execute).with(chain_builder_instance)
      chain_builder_instance.run
    end

    it 'returns subject' do
      chain_builder_instance = @chain_builder.new({})
      chain_builder_instance.run.must_equal chain_builder_instance.subject
    end
  end
end
