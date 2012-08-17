# Set of answers for a survey

class Response < ActiveRecord::Base
  belongs_to :survey
  has_many :answers
  attr_accessible :title, :body
end
