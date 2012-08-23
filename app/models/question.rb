# A specificaton for a piece of info that the survey designer wants to collect.

class Question < ActiveRecord::Base
  belongs_to :survey
  attr_accessible :content, :mandatory, :max_length
  validates_presence_of :content
  has_many :answers, :dependent => :destroy
end