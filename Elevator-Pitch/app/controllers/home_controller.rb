class HomeController < ApplicationController
  before_filter :populate_question
  before_filter :authenticate_user!, :only => [:show]
  
  def index
    @pitches = Pitch.list(:tags => tags,:page => params[:page], :per_page => Pitch::PER_PAGE, :sort_by => params[:sort_type], :category_id => params[:category_id])
    respond_to do |format|
      format.json {render :json => {:page => params[:page], :content => render_to_string(:layout => false, :partial => "home/pitches.html.erb")}}
      format.html{render :action => "index"}
    end
  end

  def why_pitch
  end

  def how_it_works
  end

  def registration_successful
  end

  #this method is used for redirection when a 401 unauthorised callback is 
  #received from twitter. configurations in config/initializers/omniauth.rb
  def failure
    redirect_to new_user_session_path, :flash => { :error => "Operation Cancelled" }
  end

  private
  def populate_question
    if user_signed_in?
      @question = PollQuestion.random(current_user)
    end
  end

  def tags
    return params[:tags] if !params[:tags].blank?
    unless params[:clicked_tag].blank?
      return params[:clicked_tag].gsub('-', ' ')
    end
  end
end
