class Photo < ActiveRecord::Base
  belongs_to :answer
  mount_uploader :image, ImageUploader
end
