# Collection of questions

class Survey < ActiveRecord::Base
  attr_accessible :name, :expiry_date, :description, :questions_attributes
  validates_presence_of :name, :expiry_date
  has_many :questions
  has_many :responses
  accepts_nested_attributes_for :questions
end
