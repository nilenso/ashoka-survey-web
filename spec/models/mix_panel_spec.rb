require "spec_helper"

describe MixPanel do
  it "creates a delayed job when an event should be tracked" do
    expect { MixPanel.track("foo") }.to change { Delayed::Job.count }.by(1)
  end
end
