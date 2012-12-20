class Category < ActiveRecord::Base
  belongs_to :category
  attr_accessible :content
  has_many :questions
  has_many :categories
end
