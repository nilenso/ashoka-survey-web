require 'ruby-progressbar'

namespace :s3 do
  desc "Populates file size for image assets from s3"
  task :cache_file_size => :environment do
    puts "Setting file size for questions"
    questions = Question.unscoped.where("image IS NOT NULL AND image_file_size IS NULL")
    bar = ProgressBar.create(:total => questions.count)
    questions.each do |question|
      size = question.image.file.size
      question.update_attribute(:image_file_size, size)
      bar.increment
    end

    puts
    puts "Setting file size for answers"

    answers = Answer.unscoped.where("photo IS NOT NULL AND photo_file_size IS NULL")
    bar = ProgressBar.create(:total => answers.count)
    answers.each do |answer|
      answer.photo_file_size = answer.photo.file.size
      answer.save
      bar.increment
    end
  end
end
