class CommentNotifications < ActionMailer::Base
  default :from => "service@mindyourpitch.com",
    :reply_to => "service@mindyourpitch.com"

  def notify_new_comment(comment) 
    @comment = comment
    @pitch = comment.commentable
    @user = @pitch.user
    
    mail(:to => @user.email,:subject => "New comment on your pitch") if @user.email.present?
  end
end
