class Choice < ActiveRecord::Base
  belongs_to :answer
  belongs_to :option
  attr_accessible :content, :option_id
  delegate :content, :to => :option
end
