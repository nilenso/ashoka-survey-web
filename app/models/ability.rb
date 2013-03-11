class Ability
  include CanCan::Ability
  attr_reader :user_info

  def own_and_shared_surveys(user_info)
    [
      'surveys.id in (SELECT "surveys".id FROM "surveys"
      LEFT OUTER JOIN participating_organizations ON participating_organizations.survey_id = surveys.id
      WHERE (surveys.organization_id = ? OR participating_organizations.organization_id = ?))',
      user_info[:org_id], user_info[:org_id]
    ]
  end

  def can_perform_on_shared_surveys(action, user_info)
    can action, Survey, own_and_shared_surveys(user_info) do |survey|
      survey.organization_id == user_info[:org_id] || survey.participating_organizations.find_by_organization_id(user_info[:org_id])
    end
  end

  def cso_admin_actions_on_shared_surveys(user_info)
    can_perform_on_shared_surveys(:read, user_info)
    can_perform_on_shared_surveys(:questions_count, user_info)
    can_perform_on_shared_surveys(:duplicate, user_info)
    can_perform_on_shared_surveys(:edit_publication, user_info)
    can_perform_on_shared_surveys(:generate_excel, user_info)
    can_perform_on_shared_surveys(:update_publication, user_info)
  end

  def cso_admin_actions_on_own_surveys(user_info)
    can :build, Survey, :organization_id => user_info[:org_id]
    can :create, Survey
    can :edit, Survey, :organization_id => user_info[:org_id]
    can :update, Survey, :organization_id => user_info[:org_id]
    can :finalize, Survey, :organization_id => user_info[:org_id]
    can :archive, Survey, :organization_id => user_info[:org_id]
    can :destroy, Survey, :organization_id => user_info[:org_id], :finalized => false
    can :report, Survey, :organization_id => user_info[:org_id]
    can :generate_excel, Survey, :organization_id => user_info[:org_id]
  end

  def cso_admin_actions_on_responses(user_info)
    can :manage, Response, :survey => { :organization_id => user_info[:org_id] }
    can :read, Response, :survey => { :organization_id => user_info[:org_id] }
    can :read, Response, :organization_id => user_info[:org_id]
    can :complete, Response, :survey => { :organization_id => user_info[:org_id] }
    can :complete, Response, :organization_id => user_info[:org_id]
    can :image_upload, Response, :organization_id => user_info[:org_id]
  end

  def admin_actions(user_info)
    can :read, Survey # TODO: Verify this
    can :questions_count, Survey
    can :read, Question
    can :read, Category
    can :read, Option
    can :read, Response # TODO: Verify this
  end

  def field_agent_actions(user_info)
    can :read, Survey, :survey_users => { :user_id => user_info[:user_id ] }
    can :generate_excel, Survey, :survey_users => { :user_id => user_info[:user_id] }
    can :questions_count, Survey, :survey_users => { :user_id => user_info[:user_id ] }
    can :create, Response, :survey => { :survey_users => { :user_id => user_info[:user_id ] } }
    can :complete, Response, :user_id  => user_info[:user_id]
    can :manage, Response, :user_id  => user_info[:user_id]
    can :image_upload, Response, :user_id => user_info[:user_id]
    can :read, Question, :survey => { :organization_id => user_info[:org_id] }
    can :read, Category, :survey => { :organization_id => user_info[:org_id] }
    can :read, Option, :question => { :survey => {:organization_id => user_info[:org_id] }}
  end

  def initialize(user_info)
    @user_info = user_info

    if user_info[:user_id].blank? || org_type_is_not_CSO # guest user (not logged in)
      can :read, Survey do |survey|
        nil
      end
    else
      role = user_info[:role]
      case role
      when 'admin'
        admin_actions(user_info)
      when 'cso_admin'
        cso_admin_actions_on_shared_surveys(user_info)
        cso_admin_actions_on_own_surveys(user_info)
        cso_admin_actions_on_responses(user_info)

        can :manage, Question, :survey => { :organization_id => user_info[:org_id] }
        can :manage, Category, :survey => { :organization_id => user_info[:org_id] }
        can :manage, Option, :question => { :survey => {:organization_id => user_info[:org_id] }}
      when 'field_agent'
        field_agent_actions(user_info)
      when 'viewer'
        can :read, Survey, :organization_id => user_info[:org_id]
        can :report, Survey, :organization_id => user_info[:org_id]
        can :read, Response, :survey => { :organization_id => user_info[:org_id] }
      end
    end
  end

  private

  def org_type_is_not_CSO
    user_info[:org_type] != "CSO" && user_info[:org_type].present?
  end
end
