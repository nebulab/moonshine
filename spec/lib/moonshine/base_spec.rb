require 'test_helper'

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
        mock_instance.subject.must_be_instance_of MockDefaultSubject
      end
    end

    describe 'when it is initialized with a subject' do
      let(:mock_instance){ MockChainBuilder.new({}, MockSubject.new) }

      it 'sets subject as requested' do
        mock_instance.subject.must_be_instance_of MockSubject
      end
    end
  end

  describe '.filter' do
    it 'instantiates a Moonshine::Filter class' do
      Moonshine::Filter.expects(:define_on).with(MockChainBuilder, :filter_name, :scope, transform: nil, default: nil)
      MockChainBuilder.filter :filter_name, :scope
    end
  end
end
