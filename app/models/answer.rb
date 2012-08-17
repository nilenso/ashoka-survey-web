# A piece of information for a question

class Answer < ActiveRecord::Base
  belongs_to :question
  attr_accessible :content, :question_id
  validates_presence_of :content
end
