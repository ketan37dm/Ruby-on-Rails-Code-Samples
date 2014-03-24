require 'utils/controllers/action_names_util.rb'
class ApplicationController < ActionController::Base
  protect_from_forgery
  include Utils::Controllers::ActionNamesUtil

  before_filter :populate_dashboard
  protected
  # this method loads all the industries which are required while creating the pitch
  def load_industries
    @industries = Industry.all
  end

  def after_sign_in_path_for(resource)
    if session[:pitch_callback_url].present?
      pitch_callback_url = session[:pitch_callback_url]
      session[:pitch_callback_url] = nil
      pitch_callback_url
    elsif session_pitch_present?
      if session[:show_redirect]
        display_pitch_path(:identifier => session[:pitch_id])
      else
        root_path
      end
    elsif current_user.pitch_created?
      super
    else
      new_pitch_path
    end
  end 

  def populate_pitch
    @pitch = Pitch.find_by_identifier(params[:pitch_id])
  end

  def populate_dashboard
    if user_signed_in?
      @total_pitches = Pitch.count
      @my_pitch_rank = current_user.pitch_rank
      @my_pitch_likes = current_user.pitch_likes
    end
  end

  private
  def session_pitch_present?
    session[:pitch_id].present?
  end

  def mobile_device?
    request.user_agent =~ /Mobile|webOS/
  end
  helper_method :mobile_device?
end
