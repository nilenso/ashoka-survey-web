class MultiChoiceQuestionDecorator < QuestionDecorator
  decorates :multi_choice_question
  delegate_all

  def input_tag(f, opts={})
    super(f,  :field => :option_ids,
              :as => :check_boxes,
              :collection => model.options.map(&:id),
              :member_label => Proc.new { |id| Option.find_by_id(id).try(:content)},
              :disabled => opts[:disabled] ? model.options.map(&:id) : [])
  end
end
