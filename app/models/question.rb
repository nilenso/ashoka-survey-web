# Sentence that can be answered

class Question < ActiveRecord::Base
  belongs_to :survey
  attr_accessible :question
  validates_presence_of :question
end
