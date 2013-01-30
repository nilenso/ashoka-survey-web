require 'spec_helper'

module Api
  module V1
    describe AuditsController do
      let(:device_id) { "fooboo400800" }
      let(:file) { mock('file') }
      let(:filename) { "#{Rails.root}/log/#{device_id}.log" }

      context "POST 'create'" do
        let(:platform_data) { {"daba" => "doo"} }

        it "creates a new audit log file for the device id" do
          File.should_receive(:new).with(filename, "a").and_return(file)
          file.stub(:puts)
          post :create, :device_id => device_id, :content => "yaba", :platform_data => platform_data
          response.should be_ok
        end

        it "creates new files for different device_ids" do
          another_device_id = "hooboo300"
          another_filename = "#{Rails.root}/log/#{another_device_id}.log"
          File.should_receive(:new).with(another_filename, "a").and_return(file)
          file.stub(:puts)
          post :create, :device_id => another_device_id, :content => "yaba", :platform_data => platform_data
          response.should be_ok
        end

        it "puts in the platform data and appends the audit log content" do
          audit_log_content = "some log content here"
          File.should_receive(:new).with(filename, "a").and_return(file)
          file.should_receive(:puts).with(platform_data)
          file.should_receive(:puts).with(audit_log_content)
          post :create, :device_id => device_id, :content => audit_log_content, :platform_data => platform_data
        end
      end

      context "PUT 'update'" do
        it "appends logs into appropriate audit log file" do
          audit_log_content = "some log content here"
          File.should_receive(:open).with(filename, "a").and_return(file)
          file.should_receive(:puts).with(audit_log_content)
          put :update, :id => device_id, :content => audit_log_content
        end
      end
    end
  end
end
