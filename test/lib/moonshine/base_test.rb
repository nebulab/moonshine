 require 'test_helper'

describe Moonshine::Base do

  let(:tale) { Tale.new }
  let(:tale_generator){ 
    empty_tale_generator = EmptyTaleGenerator.new({ beginning: true }) 
    empty_tale_generator.subject = tale
    empty_tale_generator
  }

  describe '#add_filter_to_chain' do

    let(:params) { [:beginning] }

    it 'instantiates a Moonshine::Filter' do
      Moonshine::Filter.expects(:new).with(*params.push({}))
      tale_generator.add_filter_to_chain(:beginning)
    end

    describe 'when params have options' do
    it 'instantiates a Moonshine::Filter with options' do
      Moonshine::Filter.expects(:new).with(*params.push({as_boolean: true}))
      tale_generator.add_filter_to_chain(:beginning, as_boolean: true)
    end

    end

    describe 'when params have a block' do
      it 'instantiates a Moonshine::Filter with a block' do
        a_block = Proc.new {}
        Moonshine::Filter.expects(:new).with(*params.push({}, &a_block))
        tale_generator.add_filter_to_chain(:beginning, &a_block)
      end
    end

    it 'adds a Moonshine:Filter instance to filter_chain' do
      filter = mock('a filter')
      Moonshine::Filter.stubs(:new).returns(filter)
      tale_generator.add_filter_to_chain(:beginning)
      tale_generator.chain.must_include(filter)
    end
  end

  describe '#run' do
    let(:tale_generator){ 
      empty_tale_generator = EmptyTaleGenerator.new({ beginning: true, conclusion: true }) 
      empty_tale_generator.subject = tale
      empty_tale_generator
    }

    before do
      tale_generator.add_filter_to_chain(:beginning, as_boolean: true)
      tale_generator.add_filter_to_chain(:conclusion, as_boolean: true)
    end

    it 'sends execute on each filter in chain' do
      tale_generator.chain.first.expects(:execute)
      tale_generator.chain.last.expects(:execute)
      tale_generator.run
    end

    it 'returns execute result of last filter in chain' do
      tale_generator.run.must_be_kind_of Tale
    end
  end
end

