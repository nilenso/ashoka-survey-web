# A specificaton for a piece of info that the survey designer wants to collect.

class Question < ActiveRecord::Base
  belongs_to :survey
  attr_accessible :question
  validates_presence_of :question
end
