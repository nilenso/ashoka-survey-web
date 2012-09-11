class Choice < ActiveRecord::Base
  belongs_to :answer
  attr_accessible :content
  validates_presence_of :content
end
