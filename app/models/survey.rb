class Survey < ActiveRecord::Base
  attr_accessible :description, :expiry_date, :name
end
