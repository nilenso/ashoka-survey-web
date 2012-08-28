# A specificaton for a piece of info that the survey designer wants to collect.

class Question < ActiveRecord::Base
  belongs_to :survey
  attr_accessible :content, :mandatory, :max_length, :image, :type, :survey_id
  validates_presence_of :content
  has_many :answers, :dependent => :destroy
  has_many :options, :dependent => :destroy
  has_attached_file :image, :styles => { :medium => "300x300>" }
  accepts_nested_attributes_for :options
end