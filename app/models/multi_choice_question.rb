# A question with multiple options and multiple answers

class MultiChoiceQuestion < Question
  has_many :options, :dependent => :destroy,  :foreign_key => :question_id
end