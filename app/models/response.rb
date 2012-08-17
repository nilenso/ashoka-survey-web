# Set of answers for a survey

class Response < ActiveRecord::Base
  belongs_to :survey
  has_many :answers
  validates_presence_of :survey_id
  accepts_nested_attributes_for :answers
  attr_accessible :title, :body, :answers_attributes
end
