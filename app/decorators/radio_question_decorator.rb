class RadioQuestionDecorator < QuestionWithOptionsDecorator
  decorates :radio_question
  delegate_all

  def input_tag(f, opts={})
    super(f,  :as => :radio,
              :collection => options.map { |o| [o.content, o.content, {:data => { :option_id => o.id } }] },
              :input_html => { :disabled => opts[:disabled] })
  end
end
