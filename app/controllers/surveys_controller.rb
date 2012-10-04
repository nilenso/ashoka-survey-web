require 'will_paginate/array'

class SurveysController < ApplicationController
  load_and_authorize_resource

  before_filter :survey_unpublished, :only => [:build]

  def index
    @surveys ||= []
    @surveys = @surveys.select { |survey| survey.published.to_s == params[:published] } if params[:published].present?
    @surveys = @surveys.paginate(:page => params[:page], :per_page => 10)
    if access_token.present?
      organizations = access_token.get('api/organizations').parsed
      @organization_names = organizations.reduce({}) do |hash, org|
        hash[org['id']] = org['name']
        hash
      end
    end
  end

  def destroy
    survey = Survey.find(params[:id])
    survey.destroy
    flash[:notice] = t "flash.survey_deleted"
    redirect_to(surveys_path)
  end

  def new
    @survey = Survey.new
  end

  def create
    @survey = Survey.new(params[:survey])
    @survey.organization_id = session[:user_info][:org_id]

    @survey.name ||= "Untitled Survey"
    @survey.expiry_date ||= 5.days.from_now
    @survey.description ||= "Description goes here"

    @survey.save
    flash[:notice] = t "flash.survey_created"
    redirect_to surveys_build_path(:id => @survey.id)
  end

  def build
    @survey = Survey.find(params[:id])
  end

  def publish
    survey = Survey.find(params[:survey_id])
    survey.publish
    redirect_to :back
  end

  private
  def survey_unpublished
    survey = Survey.find(params[:id])
    if survey.published?
      flash[:error] = t "flash.edit_published_survey"
      redirect_to root_path
    end
  end
end
