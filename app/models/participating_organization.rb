class ParticipatingOrganization < ActiveRecord::Base
  attr_accessible :organization_id, :survey_id
  belongs_to :survey
  validates_uniqueness_of :organization_id, :scope => :survey_id
end
