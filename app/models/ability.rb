class Ability
  include CanCan::Ability

  def initialize(user_info)


    if user_info[:user_id].blank? # guest user (not logged in)
      can :read, Survey do |survey|
        nil
      end
      can :build, Survey if Rails.env.test? # Couldn't log in a user from Capybara
    else
      role = user_info[:role]
      if role == 'admin'
        can :read, Survey # TODO: Verify this
        can :questions_count, Survey
        can :read, Question
        can :read, Option
        can :read, Response # TODO: Verify this
        #can :manage, Response, :session_token => user_info[:session_token]
      elsif role == 'cso_admin'
        can :read, Survey, ['
          surveys.id in (SELECT "surveys".id FROM "surveys"
          LEFT OUTER JOIN participating_organizations ON participating_organizations.survey_id = surveys.id
          WHERE (surveys.organization_id = ? OR participating_organizations.organization_id = ?))',
        user_info[:org_id], user_info[:org_id]] do |survey|
          survey.organization_id == user_info[:org_id] || survey.participating_organizations.find_by_organization_id(user_info[:org_id])
        end

        can :questions_count, Survey, ['
          surveys.id in (SELECT "surveys".id FROM "surveys"
          LEFT OUTER JOIN participating_organizations ON participating_organizations.survey_id = surveys.id
          WHERE (surveys.organization_id = ? OR participating_organizations.organization_id = ?))',
        user_info[:org_id], user_info[:org_id]] do |survey|
          survey.organization_id == user_info[:org_id] || survey.participating_organizations.find_by_organization_id(user_info[:org_id])
        end

        can :duplicate, Survey, ['
          surveys.id in (SELECT "surveys".id FROM "surveys"
          LEFT OUTER JOIN participating_organizations ON participating_organizations.survey_id = surveys.id
          WHERE (surveys.organization_id = ? OR participating_organizations.organization_id = ?))',
        user_info[:org_id], user_info[:org_id]] do |survey|
          survey.organization_id == user_info[:org_id] || survey.participating_organizations.find_by_organization_id(user_info[:org_id])
        end

        can :build, Survey, :organization_id => user_info[:org_id]
        can :create, Survey
        can :publish_to_users, Survey, :organization_id => user_info[:org_id]
        can :update_publish_to_users, Survey, :organization_id => user_info[:org_id]
        can :edit, Survey, :organization_id => user_info[:org_id]
        can :update, Survey, :organization_id => user_info[:org_id]
        can :finalize, Survey, :organization_id => user_info[:org_id]
        can :share_with_organizations, Survey, :organization_id => user_info[:org_id]
        can :update_share_with_organizations, Survey, :organization_id => user_info[:org_id]
        can :destroy, Survey, :organization_id => user_info[:org_id], :finalized => false
        can :report, Survey, :organization_id => user_info[:org_id]

        can :manage, Response, :survey => { :organization_id => user_info[:org_id] }
        can :read, Response, :survey => { :organization_id => user_info[:org_id] }
        can :read, Response, :organization_id => user_info[:org_id]
        can :complete, Response, :survey => { :organization_id => user_info[:org_id] }
        can :complete, Response, :organization_id => user_info[:org_id]
        can :image_upload, Response, :organization_id => user_info[:org_id]

        can :manage, Question, :survey => { :organization_id => user_info[:org_id] }
        can :manage, Option, :question => { :survey => {:organization_id => user_info[:org_id] }}
      elsif role == 'field_agent'
        can :read, Survey, :survey_users => { :user_id => user_info[:user_id ] }
        can :questions_count, Survey, :survey_users => { :user_id => user_info[:user_id ] }
        can :create, Response, :survey => { :survey_users => { :user_id => user_info[:user_id ] } }
        can :complete, Response, :user_id  => user_info[:user_id]
        can :manage, Response, :user_id  => user_info[:user_id]
        can :image_upload, Response, :user_id => user_info[:user_id]
        can :manage, Question, :survey => { :organization_id => user_info[:org_id] }
        can :manage, Option, :question => { :survey => {:organization_id => user_info[:org_id] }}
      end
    end
  end
end
