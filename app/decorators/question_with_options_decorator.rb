class QuestionWithOptionsDecorator < QuestionDecorator
  def options
    model.options.ascending
  end
end
