repo = Feature::Repository::YamlRepository.new("#{Rails.root}/config/feature.yml")
Feature.set_repository repo