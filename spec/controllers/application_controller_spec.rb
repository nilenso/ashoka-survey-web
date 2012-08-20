require 'spec_helper'

describe ApplicationController do
  # mocking index action for testing locale
  controller do
    def index
      redirect_to root_path
    end
  end

  context "when setting the locale based on params" do
    after(:each) { I18n.locale = I18n.default_locale }

    it "should set locale to french if params[:locale] is fr" do
      get :index, :locale => 'fr'
      I18n.locale.should == :fr
    end

    it "reverts to the default locale if params[:locale] is not set " do
      get :index, :locale => 'fr'
      expect { get :index }.to change { I18n.locale }.from(:fr).to(:en)
    end
  end

  context "when recieving requests without being passed the locale" do
    it "sets the locale param to I18n.locale" do
      pending "Not sure how to test this."
    end
  end
end