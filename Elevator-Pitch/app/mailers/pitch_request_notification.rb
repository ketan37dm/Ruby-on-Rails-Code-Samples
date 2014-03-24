class PitchRequestNotification < ActionMailer::Base
  default :from => "service@mindyourpitch.com",
    :reply_to => "service@mindyourpitch.com"

  def pitch_creation_request(pitch_request)
    @pitch_request = pitch_request

    mail(:to => "jparekh@idyllic-software.com,ggaglani@idyllic-software.com,service@mindyourpitch.com,anjali@idyllic-software.com",
      :subject => "New Pitch Creation Request has come in!")
  end
end
