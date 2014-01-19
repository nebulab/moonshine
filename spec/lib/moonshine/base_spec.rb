require 'test_helper'

describe Moonshine::Base do

  describe '.subject' do
    let(:mock_class){ MockClass.new({}) }

    it 'defines default_subject method on instance' do
      mock_class.must_respond_to(:default_subject)
    end

    it 'sets default_subject' do
      mock_class.default_subject.must_equal DefaultSubject
    end

    describe 'when it is initialized without a subject' do
      it 'sets subject as default subject' do
        mock_class.subject.must_be_instance_of DefaultSubject
      end
    end

    describe 'when it is initialized with a subject' do
      let(:mock_class){ MockClass.new({}, Subject.new) }

      it 'sets subject as requested' do
        mock_class.subject.must_be_instance_of Subject
      end
    end
  end
end

private

class Subject
end

class DefaultSubject
end

class MockClass < Moonshine::Base
  subject DefaultSubject
end
