# Set of answers for a survey

class Response < ActiveRecord::Base
  belongs_to :survey
  has_many :answers, :dependent => :destroy
  accepts_nested_attributes_for :answers
  attr_accessible :survey, :answers_attributes

  def five_answers
  	answers_show = answers.select { |answer| answer.text_type?}
  	answers_show.slice(0, 5)
  end
end
