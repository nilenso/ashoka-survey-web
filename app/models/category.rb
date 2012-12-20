class Category < ActiveRecord::Base
  belongs_to :category
  attr_accessible :content
  has_many :questions
  has_many :categories
  validates_presence_of :content
end
