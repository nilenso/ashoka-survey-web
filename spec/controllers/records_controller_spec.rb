require 'spec_helper'

describe RecordsController do
  describe "GET 'create'" do
    before(:each) { request.env["HTTP_REFERER"] = "http://example.com" }
    let(:category) { category = FactoryGirl.create(:category) }
    let(:response) { FactoryGirl.create(:response) }

    it "creates a new record" do
      expect {
        get 'create', :record => { :response_id => response.id, :category_id => category.id }
      }.to change { Record.count }.by 1
    end

    it "displays an error message if the creation fails" do
      get 'create'
      flash[:error].should_not be_empty
    end

    it "redirects to the last page" do
      request.env["HTTP_REFERER"] = "http://example.com"
      get 'create', :record => { :response_id => response.id, :category_id => category.id }
      response.should redirect_to('http://example.com')
    end

    it "creates blank answers for the new record" do
      5.times { FactoryGirl.create(:question, :finalized, :category => category) }
      get 'create', :record => { :response_id => response.id, :category_id => category.id }
      Record.last.answers.count.should == 5
    end
  end

  context "DELETE 'destroy'" do
    before(:each) { request.env["HTTP_REFERER"] = "http://example.com" }
    let!(:record) { FactoryGirl.create(:record) }

    it "deletes a record" do
      expect { delete :destroy, :id => record.id}.to change { Record.count }.by(-1)
      flash[:notice].should_not be_nil
    end

    it "redirects to the previous page" do
      delete :destroy, :id => record.id
      response.should redirect_to "http://example.com"
    end
  end
end
