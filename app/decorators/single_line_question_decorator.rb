class SingleLineQuestionDecorator < QuestionDecorator
  decorates :single_line_question
  delegate_all

  def input_tag(f, opts={})
    super(f, :as => :string,
          :input_html => { :disabled => opts[:disabled],
                           :class => model.max_length ? "max_length" : nil,
                           :data => { :max_length => model.max_length }})
  end
end
