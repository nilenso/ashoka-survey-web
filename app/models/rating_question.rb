# A question with a photo as the answer

class RatingQuestion < Question
  attr_accessible :max_length
  validates_numericality_of :max_length, :only => :integer, :greater_than => 0, :allow_nil => true

  def report_data
    answers_content = answers.map(&:content)
    answers_content.uniq.inject([]) do |data, content|
      data.push [content.to_i, answers_content.count(content)]
    end
  end

  def min_value_for_report
    0
  end

  def max_value_for_report
    max_length
  end
end
