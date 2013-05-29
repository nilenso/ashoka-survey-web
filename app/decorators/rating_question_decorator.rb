class RatingQuestionDecorator < QuestionDecorator
  decorates :rating_question
  delegate_all

  def input_tag(f, opts={})
    string = ERB.new "
      <div class='rating'>
        <%= f.label label %>
        <%= '<abbr>*</abbr>' if model.mandatory %>
        <%= f.input :content, :as => :hidden %>
        <% answer = f.object %>
        <div class='star'
            data-number-of-stars='<%= model.max_length %>'
            data-score='<%= answer.content %>'>
        </div>
        <%= f.semantic_errors :content if (f.semantic_errors :content) %>
      </div>"

    string.result(binding).force_encoding('utf-8').html_safe
  end
end
