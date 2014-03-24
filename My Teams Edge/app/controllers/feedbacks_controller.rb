class FeedbacksController < ApplicationController
  
  def new
    @feedback = Feedback.new
  end

  def create 
    @feedback = Feedback.new(params[:feedback])
    if @feedback.valid?
      NotificationMailer.send_contact_message(@feedback).deliver
      redirect_to root_path, :flash => { :success => "Thanks for the message, we will be in touch soon." }
    else
      render "new"
    end
  end

end
