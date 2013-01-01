if defined?(Footnotes) && Rails.env.development?
  Footnotes.run! # first of all
  Footnotes::Filter.prefix = 'subl://open?url=file://%s&line=%d&column=%d'
end
