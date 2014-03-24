class NotificationMailer < ActionMailer::Base

  def welcome_email(user)
    @user = user
    mail( :from => "no-reply@myteamsedge.com", :to => user.email, :subject => "Welcome to MyTeamsEdge" )
  end

  def support_email(user)
    @user = user
    mail( :from => "support@myteamsedge.com", :to => user.email, :subject => "Welcome to MyTeamsEdge" )
  end

  #send email to the payer
  def payment_invoice(user)
  	@user = user
  	mail(
  			:from => "support@myteamsedge.com",
  			:to =>  user.email,
  			:subject => "Payment Recipet"
  		)
  end

  #send successful registration email to te user
  def registration_successful(user)
  	@user = user
  	mail(
  			:from => "support@myteamsedge.com",
  			:to => user.email,
  			:subject => "Welcome to MyTeamsEdge! Your MTE Account is ready, click the link below to complete your account."
  		)
  end

  def send_contact_message(contact)
    # mail admin user's reply posted on contacts page
    @contact = contact
    mail(
      :from => "#{@contact.name} <#{@contact.email}>",
      :to => "no-reply@myteamsedge.com",
      :subject => @contact.reason,
      :reply_to => @contact.email
    )
  end

  #send email to admin after a new account has been created for any of the 3 packages
  def new_account_information(payer) 
    @payer = payer
    @organization_name = @payer.associated_organization.name
    @package_type = @payer.subscription.stripe_plan_id.upcase.humanize.titleize 
    @user_sports = @payer.user_sports.all( :include => [ :user , :sport ] )
    mail(
      :from => "support@myteamsedge.com",
      :to => "no-reply@myteamsedge.com",
      :subject => "New Account Created"
    )
  end

  def new_sport_notification(user)
    @user = user
    mail(
      :from => "no-reply@myteamsedge.com",
      :to => @user.email,
      :subject => "New Sport Added"
    )

  end

  def change_email_notification(user)
    @user = user
    mail(
      :from => "no-reply@myteamsedge.com",
      :to => @user.email,
      :subject => "New email confirmation"
    )
  end

  def send_sport_added_notification(user, user_sport)
    @user = user
    @user_sport = user_sport
    mail(
      :from => "no-reply@myteamsedge.com",
      :to => @user.email,
      :subject => "New Sport confirmation"
    )
  end
end
