class MultiChoiceQuestionDecorator < QuestionDecorator
  decorates :multi_choice_question

  def input_tag(f, opts={})
    f.input :option_ids,
            :as => :check_boxes,
            :label => label,
            :required => model.mandatory,
            :collection => model.options.map(&:id),
            :member_label => Proc.new { |id| Option.find_by_id(id).try(:content)},
            :disabled => opts[:disabled] ? model.options.map(&:id) : []
  end
end
