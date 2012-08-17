class Answer < ActiveRecord::Base
  belongs_to :question
  attr_accessible :content
  validates_presence_of :content
end
