namespace :db do
  desc "Delete all the data islands"
  task :delete_data_islands => :environment do
    orphaned_options = Option.where('question_id NOT IN (?)', Question.pluck("id"))
    orphaned_options.delete_all
  end
end
