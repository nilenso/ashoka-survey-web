class ParticipatingOrganization < ActiveRecord::Base
  attr_accessible :organization_id, :survey_id
  belongs_to :survey
end
