class Registration < ActionMailer::Base
  default :from => "service@mindyourpitch.com",
    :reply_to => "service@mindyourpitch.com"

  def note(user)
    @user = user

    mail(:to => user.email,
      :subject => "Welcome To Mind Your Pitch!")
  end
end
