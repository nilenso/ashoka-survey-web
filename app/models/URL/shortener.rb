require 'uri'

class URL::Shortener
  def initialize(url)
    if url =~ URI::regexp
      @url = url
    else
      raise ArgumentError
    end
    @client = Bitly.client
  end

  def shorten
    @client.shorten(@url).short_url
  end
end
