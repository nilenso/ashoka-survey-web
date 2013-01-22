# A container for other questions

class MultiRecordQuestion < Question
  has_many :questions
end
