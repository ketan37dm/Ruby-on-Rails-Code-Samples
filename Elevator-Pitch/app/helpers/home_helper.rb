module HomeHelper
  require 'bitly'
  
  # this method will return the shortened url to be shared on twitter using Bitly api
  def get_short_url(link)
    client = Bitly.client
    shortened_url = client.shorten(link)
    return shortened_url.short_url 
  end

  # this method will return the text of the pitch to be shared on twitter using Bitly api
  def get_tweet_text(text)
    return sanitize(strip_tags(strip_links(text))).split("\r\n").join[0..99]
  end

  def my_pitch_class(pitch)
    return "my-pitch-color" if pitch.my_pitch?(current_user)
  end
end
