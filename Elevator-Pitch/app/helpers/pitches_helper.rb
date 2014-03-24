module PitchesHelper
  def video_tag(pitch)
    width = mobile_device? ? pitch.computer_width : pitch.phone_width
    height = mobile_device? ? pitch.computer_height : pitch.phone_height
    "<iframe width='#{width}' align='left' height='#{height}' src='#{pitch.embed_url}' frameborder='0' allowfullscreen></iframe>".html_safe
  end
end
