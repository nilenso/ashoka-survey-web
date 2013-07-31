class V2SurveyBuilder::SurveysController < ApplicationController
  load_resource :only => :index
  authorize_resource
  after_filter(:only => [:create]) { send_to_mixpanel("Survey created") }
  after_filter(:only => [:destroy]) { send_to_mixpanel("Survey destroyed", {:survey => @survey.name}) if @survey.present? }
  after_filter(:only => [:finalize]) { send_to_mixpanel("Survey finalized", {:survey => @survey.name}) if @survey.present? }
  after_filter(:only => [:archive]) { send_to_mixpanel("Survey archived", {:survey => @survey.name}) if @survey.present? }
  before_filter :redirect_to_https, :only => :index

  def new
    @survey = Survey.new
  end

  def index
    @surveys ||= Survey.none
    filtered_surveys = SurveyFilter.new(@surveys, params[:filter]).filter
    paginated_surveys = filtered_surveys.most_recent.paginate(:page => params[:page], :per_page => 10)
    @surveys = paginated_surveys.decorate
    @organizations = Organization.all(access_token)
  end

  def create
    @survey = Survey.new(params[:survey])
    @survey.organization_id = current_user_org
    @survey.expiry_date = 5.days.from_now

    if @survey.save
      flash[:notice] = t "flash.survey_created"
      redirect_to v2_survey_builder_survey_build_path(:survey_id => @survey.id)
    else
      flash[:error] = I18n.t("v2_survey_builder.surveys.create.flash_error_message")
      render :new
    end
  end

  def build
    @survey = SurveyDecorator.find(params[:survey_id])
  end

  def destroy
    @survey = Survey.find(params[:id])
    @survey.delete_self_and_associated if @survey.deletable?
    flash[:notice] = t "flash.survey_deleted"
    redirect_to(surveys_path)
  end

  def finalize
    @survey = Survey.find(params[:survey_id])
    @survey.finalize
    flash[:notice] = t "flash.survey_finalized", :survey_name => @survey.name
    redirect_to edit_survey_publication_path(@survey.id)
  end

  def archive
    @survey = Survey.find(params[:survey_id])
    if @survey.archive
      flash[:notice] = t("flash.survey_archived", :survey_name => @survey.name)
    else
      flash[:error] = @survey.errors.messages
    end
    redirect_to root_path
  end

  def report
    @survey = SurveyDecorator.find(params[:id])
    responses = Response.accessible_by(current_ability)
    @complete_responses_count = responses.where(:status => 'complete').count
    @markers = @survey.responses.where(:status => "complete").to_gmaps4rails
  end

  private

  def redirect_to_https
    # Need request.head? because mobile makes a HEAD request to this same path and Titanium
    # since doesn't follow redirects, we can't redirect to https:// in that case.
    redirect_to :protocol => "https://" if !request.ssl? && !request.head?
  end
end
