# encoding: utf-8

class ImageUploader < CarrierWave::Uploader::Base

  include CarrierWave::RMagick

  before :cache, :generate_secure_token

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def cache_dir
    "uploads/tmp"
  end

  version :thumb do
    process :resize_to_fit => [100, 100]
  end

  version :medium do
    process :resize_to_fit => [300, 300]
  end

  def filename
    if original_filename.present?
      model.photo_secure_token
    end
  end

  protected

  def generate_secure_token(file)
    model.photo_secure_token = SecureRandom.hex(5)
  end
end
