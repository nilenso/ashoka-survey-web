class DateQuestionDecorator < QuestionDecorator
  decorates :date_question

  def input_tag(f, opts={})
    super(f,  :as => :string,
              :input_html => { :disabled => opts[:disabled], :class => 'date' })
  end
end
