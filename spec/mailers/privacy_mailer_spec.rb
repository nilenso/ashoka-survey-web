require 'spec_helper'

describe PrivacyMailer do
  let(:recipients) { 5.times.map { FactoryGirl.build(:user) } }
  let(:organization) { FactoryGirl.build(:organization) }

  context "when an organization is de-registered" do
    it "sends the deactivation mail" do
      expect{ PrivacyMailer.deactivation_mail(organization, recipients).deliver }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it "sends an email to the users passed in" do
      user_1 = FactoryGirl.build(:user, :email => "x@example.com")
      user_2 = FactoryGirl.build(:user, :email => "y@example.com")
      email = PrivacyMailer.deactivation_mail(organization, [user_2, user_1])
      email.should bcc_to("x@example.com", "y@example.com")
    end

    it "assigns the organization name" do
      organization = FactoryGirl.build(:organization, :name => "foo")
      email = PrivacyMailer.deactivation_mail(organization, [FactoryGirl.build(:user)])
      email.body.should include "foo"
    end

    it "includes organization name in the subject" do
      organization = FactoryGirl.build(:organization, :name => "foo")
      email = PrivacyMailer.deactivation_mail(organization, [FactoryGirl.build(:user)])
      email.should have_subject /foo/
    end
  end
end
