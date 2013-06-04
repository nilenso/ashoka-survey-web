class AnswerPhotoWorker < CarrierWave::Workers::StoreAsset
  def after(job)
    answer = Answer.find(id)
    answer.update_photo_size!
  end
end
