class ContactNotification < ActionMailer::Base
  default :from => "service@mindyourpitch.com",
    :reply_to => "service@mindyourpitch.com"

  def send_contact_notification(contact)
    @contact = contact

    mail(:to => "jparekh@idyllic-software.com,ggaglani@idyllic-software.com,service@mindyourpitch.com,anjali@idyllic-software.com",
      :subject => "Some one is trying to contact us for MindYourPitch!")
  end
end
