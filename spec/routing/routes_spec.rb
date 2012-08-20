require 'spec_helper'

describe "Routes" do
  context "when routing based on locale" do
    it "routes /fr/surveys to Surveys#index in French" do
      get("/fr/surveys").should route_to("surveys#index", :locale => 'fr')
    end

    it "routes /en/surveys to Surveys#index in English" do
      get("/en/surveys").should route_to("surveys#index", :locale => 'en')
    end

    it "routes /surveys to Surveys#index in default locale" do
      get("/surveys").should route_to("surveys#index")
    end

    it "does not route an invalid locale" do
      get("/abc/surveys").should_not be_routable
    end

    context "for the root page" do
      it "routes / to the root page in the default locale" do
        get("/").should route_to("surveys#index")
      end

      it "routes /fr to the root page in French" do
        get("/fr").should route_to("surveys#index", :locale => 'fr')
      end

      it "does not route an invalid locale" do
        get("/abc").should_not be_routable
      end
    end
  end
end
