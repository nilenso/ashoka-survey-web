# A question with a single line answer

class SingleLineQuestion < Question
  attr_accessible :max_length
  validates_numericality_of :max_length, :only => :integer, :greater_than => 0, :allow_nil => true
end
