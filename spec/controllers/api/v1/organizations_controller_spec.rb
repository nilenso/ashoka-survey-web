require "spec_helper"

module Api
  module V1
    describe OrganizationsController do
      before(:each) { sign_in_as("super_admin") }

      context "DELETE 'destroy'" do
        it "kicks off a delayed job" do
          organization = FactoryGirl.build(:organization)
          expect { delete :destroy, :id => organization.id }.to change { Delayed::Job.count }.by(1)
        end

        it "deletes the organization's surveys" do
          organization = FactoryGirl.build(:organization)
          survey = FactoryGirl.create(:survey, :organization_id => organization.id)
          delete :destroy, :id => organization.id
          Delayed::Worker.new.work_off
          Survey.find_by_id(survey.id).should be_nil
        end

        it "deletes the organization's responses" do
          organization = FactoryGirl.build(:organization)
          survey = FactoryGirl.create(:survey, :organization_id => organization.id)
          response = FactoryGirl.create(:response, :organization_id => organization.id, :survey => survey)
          delete :destroy, :id => organization.id
          Delayed::Worker.new.work_off
          Response.find_by_id(response.id).should be_nil
        end
      end
    end
  end
end
