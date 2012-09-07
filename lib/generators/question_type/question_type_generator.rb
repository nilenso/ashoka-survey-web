class QuestionTypeGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)

  def create_rails_model
    template "rails_model.rb", "app/models/#{file_name}.rb"
    template "rails_model_spec.rb", "spec/models/#{file_name}_spec.rb"
  end

  def create_backbone_model
    template "backbone_model.rb", "app/assets/javascripts/backbone/models/#{file_name}_model.js.coffee"
    template "backbone_model_spec.rb", "spec/javascripts/backbone/models/#{file_name}_model_spec.js.coffee"
  end

  def create_backbone_views
    template "backbone_dummy_view.rb", "app/assets/javascripts/backbone/views/dummies/#{file_name}_view.js.coffee"
    template "backbone_actual_view.rb", "app/assets/javascripts/backbone/views/questions/#{file_name}_view.js.coffee"
  end

  def create_backbone_templates
    copy_file "backbone_dummy_template.rb", "app/views/templates/dummies/_#{file_name}.html.erb"
    copy_file "backbone_actual_template.rb", "app/views/templates/questions/_#{file_name}.html.erb"
  end

  def help_message
    puts
    puts "Don't forget to add the relevant lines in the following files:"
    puts " - survey_model.js.coffee"
    puts " - dummy_pane_view.js.coffee"
    puts " - settings_pane_view.js.coffee"
    puts " - picker_pane_view.js.coffee"
    puts " - build.html.erb"
  end
end
