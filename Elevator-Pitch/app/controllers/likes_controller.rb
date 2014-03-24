class LikesController < ApplicationController
  before_filter :populate_pitch
  before_filter :authenticate_user!, :confirm_unique_like, :except => [:remember]
  
  # each record consists of : pitch id, user who liked the pitch
  def create
    like = Like.new
    like.user = current_user
    like.pitch = @pitch
    like.save!
  end

  def remember
    session[:pitch_id] = @pitch.identifier
    session[:show_redirect] = params[:show_redirect].present? ? nil : params[:show_redirect]
    redirect_to new_user_session_path, :flash => {:error => "Please sign in or sign up to like a pitch"}
  end

  private
  def confirm_unique_like
    if @pitch.liked?(current_user)
      respond_to do |format|
        format.json{render :json => {:error => 'Unprocessable Entity'}, :status => :unprocessable_entity}
        format.html{redirect_to new_session_path}
      end
      false
    end
  end
end