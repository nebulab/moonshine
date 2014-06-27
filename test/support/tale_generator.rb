class TaleGenerator < Moonshine::Base 
  subject -> { Tale.new }
  param :beginning, default: true, as_boolean: true
  param :character
  param :in_the_middle, call: :before_conclusion
  param :ending, call: :conclusion, as_boolean: true
end
