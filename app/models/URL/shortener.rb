require 'URI'

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
    foo = @client.shorten(@url)
    foo.short_url
  end
end
