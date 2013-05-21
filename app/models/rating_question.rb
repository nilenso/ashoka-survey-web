class RatingQuestion < Question
  attr_accessible :max_length
  validates_numericality_of :max_length, :only => :integer, :greater_than => 0, :allow_nil => true

  DEFAULT_MAX_LENGTH = 5

  def report_data
    answers_grouped_by_content = answers_for_reports.count(:group => 'answers.content')
    answers_grouped_by_content.map { |content,count| [content.to_f, count] }
  end

  def min_value_for_report
    0
  end

  def max_value_for_report
    max_length || DEFAULT_MAX_LENGTH
  end

end
