require 'spec_helper'

describe Moonshine::Base do

  describe '.subject' do
    let(:mock_instance){ MockChainBuilder.new({}) }

    before do
      MockChainBuilder.subject MockDefaultSubject
    end

    it 'defines default_subject method on instance' do
      mock_instance.must_respond_to(:default_subject)
    end

    it 'sets default_subject' do
      mock_instance.default_subject.must_equal MockDefaultSubject
    end

    describe 'when it is initialized without a subject' do
      it 'sets subject as default subject' do
        mock_instance.subject.must_equal MockDefaultSubject
      end
    end

    describe 'when it is initialized with a subject' do
      let(:mock_instance){ MockChainBuilder.new({}, MockSubject) }

      it 'sets subject as requested' do
        mock_instance.subject.must_equal MockSubject
      end
    end
  end

  describe '.filter' do
    it 'instantiates a Moonshine::Filter class' do
      Moonshine::Filter.expects(:define_on).with(MockChainBuilder, :filter_name, :scope, transform: nil, default: nil)
      MockChainBuilder.filter :filter_name, :scope
    end
  end

  describe '#all' do
    let(:subject){ stub_everything('subject') }

    before do
      MockChainBuilder.filter :first_name, :by_first_name
      MockChainBuilder.filter :last_name, :by_last_name
      MockChainBuilder.filter :gender, :by_gender
      MockChainBuilder.filter :age, :by_age
    end

    it 'calls the filters chain based on filters' do
      chain_builder = MockChainBuilder.new({ first_name: 'Alessio', last_name: 'Rocco', gender: :male }, subject)
      chain_builder.expects(:first_name).with('Alessio')
      chain_builder.expects(:last_name).with('Rocco')
      chain_builder.expects(:gender).with(:male)
      chain_builder.expects(:age).never
      chain_builder.all
    end

    it 'returns subject' do
      chain_builder = MockChainBuilder.new({ first_name: 'Alessio', last_name: 'Rocco', gender: :male }, subject)
      subject.stubs(:by_first_name).returns(subject)
      subject.stubs(:by_last_name).returns(subject)
      subject.stubs(:by_gender).returns(subject)
      chain_builder.all.must_equal subject
    end
  end
end
