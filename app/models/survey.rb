# Collection of questions

class Survey < ActiveRecord::Base
  attr_accessible :name, :expiry_date, :description, :questions_attributes
  validates_presence_of :name, :expiry_date
  validate :expiry_date_should_not_be_in_past
  has_many :questions, :dependent => :destroy
  has_many :responses, :dependent => :destroy
  accepts_nested_attributes_for :questions

  private

  def expiry_date_should_not_be_in_past
		if !expiry_date.blank? and expiry_date < Date.current
		 	errors.add(:expiry_date, "can't be in the past")
		end
  end
end
