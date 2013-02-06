class QuestionDecorator < Draper::Base
  decorates :question
  include ElementNumberable

  def input_tag(f, opts={})
    f.input (opts[:field] || :content), opts.merge(:label => label, :required => mandatory)
  end

  def label
    question_number + ")  " + content
  end
end
