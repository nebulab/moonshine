require 'test_helper'

describe 'Given a class to generate a tale' do

  let(:tale_generator){ TaleGenerator.new({}) }

  describe 'when no params' do
    it 'tell this story' do
      tale_generator.run.story.must_equal "#{Tale::BEGINNING}"
    end
  end

  describe "when params are { ending: true }" do
    it 'tell this story' do
      tale_generator.params = { ending: true }
      tale_generator.run.story.must_equal "#{Tale::BEGINNING} #{Tale::CONCLUSION}"
    end
  end

  describe "when params are { character: 'a developer' }" do
    it 'tell this story' do
      tale_generator.params = { character: 'a developer' }
      tale_generator.run.story.must_equal "#{Tale::BEGINNING} a developer"
    end
  end

  describe "when params are { character: 'a developer' }" do
    it 'tell this story' do
      tale_generator.params = { character: 'a developer',
                                in_the_middle: 'that write a gem' }
      tale_generator.run.story.must_equal(
        "#{Tale::BEGINNING} a developer that write a gem"
      )
    end
  end
end

