class QuestionDecorator < Draper::Base
  decorates :question
  include ElementNumberable

  def input_tag(f, opts={})
    f.input (opts[:field] || :content), opts.merge(:label => label, :required => mandatory)
  end

  def content_with_answer_count
    question.content + " " + I18n.t('surveys.report.total', :count => question.answers.complete.count)
  end

  def label
    question_number + ")  " + content
  end
end
