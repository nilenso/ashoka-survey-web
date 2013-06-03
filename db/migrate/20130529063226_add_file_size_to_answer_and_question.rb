class AddFileSizeToAnswerAndQuestion < ActiveRecord::Migration
  def change
    add_column :answers, :photo_file_size, :integer
    add_column :questions, :image_file_size, :integer
    puts "*" * 50
    puts "Please run `rake s3:cache_file_size`"
    puts "to add file-sizes for images already on S3"
    puts "*" * 50
  end
end
