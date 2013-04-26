require 'spec_helper'

module Api
  module V1
    describe JobsController do
      context "GET 'alive'" do
        it "returns true (as JSON) if the given job is running" do
          job = Delayed::Job.enqueue(Reports::Excel::Job.new)
          get :alive, :id => job.id
          response.should be_ok
          JSON.parse(response.body).should == { 'alive' => true }
        end

        it "returns false (as JSON) if the given job is not running" do
          get :alive, :id => 42
          response.should be_ok
          JSON.parse(response.body).should == { 'alive' => false }
        end
      end
    end
  end
end
