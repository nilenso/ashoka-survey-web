require 'spec_helper'

describe URL::Shortener do
  before(:each) do
    mock_url = double
    mock_url.stub(:short_url).and_return("http://bit.ly/foo")
    mock_client = double
    mock_client.stub(:shorten).and_return(mock_url)
    Bitly.stub(:client).and_return(mock_client)
  end

  it "returns a new URL representing the passed in URL" do
    url = "http://example.com/some/long/url"
    URL::Shortener.new(url).shorten.should be_a_url
  end

  it "raises an ArgumentError if the string passed in is not a URL" do
    expect { URL::Shortener.new("foo") }.to raise_error
  end
end
