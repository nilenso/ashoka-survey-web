require 'spec_helper'

describe SurveysController do
  context "GET 'new'" do
    before { get :new }

    it { should assign_to(:survey) }
    it { should respond_with(:ok) }
    it { should render_template(:new) }
  end
end
