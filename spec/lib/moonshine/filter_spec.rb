require 'test_helper'

describe Moonshine::Filter do
  let(:mock_instance) { MockChainBuilder.new({}) }

  describe '.define_on' do
    before do
      Moonshine::Filter.define_on(MockChainBuilder, :filter_name, :scope_method)
    end

    it 'defines a delegator on the class object' do
      mock_instance.must_respond_to :filter_name
    end

    describe 'defined method' do
      it 'delegates to method with same name on klass.subject' do
        mock_instance.subject.expects(:scope_method).with(123)
        mock_instance.filter_name 123
      end

      describe 'when transform is set' do
        it 'calls transform method on klass' do
          Moonshine::Filter.define_on(MockChainBuilder, :filter_name, :scope_method, transform: :clean)
          mock_instance.expects(:clean).with(123)
          mock_instance.filter_name 123
        end
      end

      describe 'when default is set' do
        before do
          Moonshine::Filter.define_on(MockChainBuilder, :filter_name, :scope_method, default: 567)
        end

        describe 'and value is blank' do
          it 'delegates to klass.subject with default value' do
            mock_instance.subject.expects(:scope_method).with(567)
            mock_instance.filter_name nil
          end
        end

        describe 'and value is not blank' do
          it 'delegates to klass.subject with given value' do
            mock_instance.subject.expects(:scope_method).with(123)
            mock_instance.filter_name 123
          end
        end
      end

    end
  end
end
