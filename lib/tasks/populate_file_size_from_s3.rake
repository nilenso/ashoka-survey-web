require 'ruby-progressbar'

namespace :s3 do
  desc "Populates file size for image assets from s3"
  task :cache_file_size => :environment do
    puts "Setting file size for questions"
    questions = Question.unscoped.where("image IS NOT NULL AND photo_file_size IS NULL")
    questions_count = questions.count
    bar = ProgressBar.create(:format => '%a |%b>%i| %p%% %t', :total => questions_count)
    questions.each do |question|
      file = question.image.file
      question.update_image_size! if file.exists?
      bar.increment
    end

    puts
    puts "Finished processing #{questions_count} questions."
    puts
    puts "Setting file size for answers"

    answers = Answer.unscoped.where("photo IS NOT NULL AND photo_file_size IS NULL")
    answers_count = answers.count
    bar = ProgressBar.create(:format => '%a |%b>%i| %p%% %t', :total => answers_count)
    answers.each do |answer|
      answer.update_photo_size!
      bar.increment
    end

    puts
    puts "Finished processing #{answers_count} answers."
  end
end
