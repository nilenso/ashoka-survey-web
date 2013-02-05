class CategoryDecorator < Draper::Base
  decorates :category

  def create_record_link(response_id)
  end


  def category_name(record_id, response_id, cache)
    # TODO: REFACTOR
    # Display a category once only, unless its inside a multi-record (show it once per record then).
    unless cache.include?([model.id, record_id])
      cache << [model.id, record_id]

      string = ERB.new "
        <%= model.category.decorate.category_name(record_id, response_id, cache) if model.category %>

        <div class='category <%= 'hidden sub_question' if model.sub_question? %>'
             data-nesting-level='<%= model.nesting_level %>'
             data-parent-id='<%= model.parent_id %>'
             data-id='<%= model.id %>'
             data-record-id='<%= record_id %>'
             data-category-id='<%= model.category_id %>'>
          <h2>
            <%= ResponseDecorator.question_number(category) %>)
            <%= model.content %>
            <%= model.decorate.create_record_link(response_id) %>
          </h2>
        </div>
      "
      string.result(binding).force_encoding('utf-8').html_safe
    end
  end
end