class ParticipatingOrganization < ActiveRecord::Base
  attr_accessible :organization_id, :survey_id
  belongs_to :survey
  validates_uniqueness_of :organization_id, :scope => :survey_id
  validates_presence_of :organization_id, :survey_id
  validate :survey_must_be_finalized

  def survey_must_be_finalized
    unless survey.try(:finalized?)
      errors.add(:survey, I18n.t('participating_organizations.validations.require_finalized'))
    end
  end
end
