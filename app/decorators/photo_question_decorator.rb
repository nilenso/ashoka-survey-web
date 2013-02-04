class PhotoQuestionDecorator < QuestionDecorator
  decorates :photo_question

  def input_tag(f, opts={})
    answer = f.object
    photo_url = opts[:disabled] ? answer.photo_url : answer.photo_url(:medium)

    "#{(h.image_tag photo_url, :class => 'medium' if answer.photo_url.present?)}
     #{(f.input :photo,
                :as => :file,
                :required => model.mandatory,
                :label => label,
                :input_html => { :disabled => opts[:disabled] })}".html_safe
  end
end
