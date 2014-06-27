class Tale

  BEGINNING = 'long time ago ther was'
  CONCLUSION = 'and they lived happily ever after'

  def initialize
    @story = {}
  end

  def story
    story = []
    story << @story[:beginning]
    story << @story[:character]
    story << @story[:before_conclusion]
    story << @story[:conclusion]
    story.delete(nil)
    story.join(' ')
  end

  def character(name)
    @story[:character] = name
    self
  end

  def beginning
    @story[:beginning] = BEGINNING
    self
  end

  def before_conclusion(value)
    @story[:before_conclusion] = value
    self
  end

  def conclusion
    @story[:conclusion] = CONCLUSION
    self
  end
end
