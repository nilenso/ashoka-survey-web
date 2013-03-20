class Record < ActiveRecord::Base
  belongs_to :category
  belongs_to :response
  has_many :answers, :dependent => :destroy
  attr_accessible :category_id, :response_id

  validates_presence_of :category_id
end
