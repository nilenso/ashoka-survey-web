class Choice < ActiveRecord::Base
  belongs_to :answer
  belongs_to :option
  attr_accessible :content, :option_id

  def content
    option.content
  end
end
