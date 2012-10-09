class RadioQuestion < Question 
  has_many :options, :dependent => :destroy, :foreign_key => :question_id
end