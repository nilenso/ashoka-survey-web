# encoding: utf-8

class ImageUploader < CarrierWave::Uploader::Base

  include CarrierWave::RMagick

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
    "#{secure_token(10)}" if original_filename.present?
  end

  protected
  def secure_token(length=16)
    unless model.photo_secure_token
      model.photo_secure_token = SecureRandom.hex(length / 2)
      model.save
    end
    model.photo_secure_token
  end
end
