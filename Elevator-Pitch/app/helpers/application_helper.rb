module ApplicationHelper
  include TweetButton
  TweetButton.default_tweet_button_options = {:via => "MindYourPitch", :count => "none"}
  
  def get_user_status(user)
    status = user.is_individual
    if status.nil?
      return true
    else
      return status
    end
  end

  def show_introduction?
    current_user.nil? && controller_path == 'home' && action_name == 'index'
  end

  def all_categories
    Category.all
  end

  def is_link_active(con, act)
    return "is_nav_active" if ( con == params[:controller] && act == params[:action] )
  end

  def comment_timestamp(comment)
    comment.created_at.strftime(COMMENT_TIME_FORMAT)
  end
  
  def show_statistics?
    user_signed_in? && pitch_created? && controller_path == 'home' && action_name == 'index'
  end
  
  def show_poll?
    user_signed_in? && pitch_created? && controller_path == 'home' && action_name == 'index'
  end
  
  def pitch_created?
    current_user && !current_user.pitch.blank?
  end

  def create_pitch_callout?
    !pitch_created? && !editing_profile?
  end

  def editing_profile?
    controller_path == 'registrations' && ['edit','change_password','update'].include?(action_name)
  end
  
end
