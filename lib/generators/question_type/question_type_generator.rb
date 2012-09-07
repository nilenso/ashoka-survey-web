class QuestionTypeGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)

  def create_rails_models
    template "rails_model.rb", "app/models/#{file_name}.rb"
    template "rails_model_spec.rb", "spec/models/#{file_name}_spec.rb"
  end
end
