# Collection of questions

class Survey < ActiveRecord::Base
  attr_accessible :name, :expiry_date, :description
  validates_presence_of :name, :expiry_date
  has_many :questions
end
