class Record < ActiveRecord::Base
  belongs_to :category
  has_many :answers, :dependent => :destroy
  attr_accessible :category_id, :response_id
end
