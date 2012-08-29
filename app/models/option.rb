class Option < ActiveRecord::Base
  belongs_to :question
  attr_accessible :content, :question_id
end
