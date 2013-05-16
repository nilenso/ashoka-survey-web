# A question with a photo as the answer

class PhotoQuestion < Question
  attr_accessible :max_length
  validates_numericality_of :max_length, :only => :integer, :greater_than => 0, :allow_nil => true
  before_create :mark_private

  private

  def mark_private
    self.private = true
  end
end
