class QuestionDecorator < Draper::Base
  decorates :question

  def input_tag(f, opts={})
    f.input :content, opts.merge(:label => label, :required => model.mandatory)
  end

  def label
    ResponseDecorator.question_number(model) + ")  " + model.content
  end
end
