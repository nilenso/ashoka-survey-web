class DateQuestionDecorator < QuestionDecorator
  decorates :date_question
  delegate_all

  def input_tag(f, opts={})
    super(f,  :as => :string,
              :input_html => { :disabled => opts[:disabled], :class => 'date' })
  end
end
