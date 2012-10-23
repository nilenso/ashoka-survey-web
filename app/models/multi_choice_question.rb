# A question with multiple options and multiple answers

class MultiChoiceQuestion < Question
  has_many :options, :dependent => :destroy,  :foreign_key => :question_id

  def report_data
    choice_ids = Choice.joins(:answer => :response).where(:responses => {:status => 'complete'}, :option_id => options.map(&:id)).map(&:option_id)
    options.map { |option| [option.content, choice_ids.count(option.id)] }
  end
end