class MultiChoiceQuestionDecorator < QuestionWithOptionsDecorator
  decorates :multi_choice_question
  delegate_all

  def input_tag(f, opts={})
    super(f,  :field => :option_ids,
              :as => :check_boxes,
              :collection => options.map(&:id),
              :member_label => Proc.new { |id| Option.find_by_id(id).try(:content)},
              :disabled => opts[:disabled] ? options.map(&:id) : [])
  end
end
