module ApplicationHelper
  def link_to_add_question_fields(name, f)  
    # http://railscasts.com/episodes/196-nested-model-form-revised
    field = f.semantic_fields_for(:questions) do |builder|
      render('questions/new', :f => builder)
    end
    link_to(name, "#", :class => "add_question_field", :data => { :field => field.gsub("\n", '')} )
  end
end
