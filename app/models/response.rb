# Set of answers for a survey

class Response < ActiveRecord::Base
  belongs_to :survey
  has_many :answers
  accepts_nested_attributes_for :answers
  attr_accessible :survey, :answers_attributes
end
