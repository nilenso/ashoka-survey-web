class MultilineQuestionDecorator < QuestionDecorator
  decorates :multiline_question

  def input_tag(f, opts={})
    super(f, :as => :text,
          :input_html => { :disabled => opts[:disabled],
                           :class => model.max_length ? "max_length" : nil,
                           :data => { :max_length => model.max_length },
                           :rows => 4})
  end
end
