class SessionsController < Devise::SessionsController
  layout false , :only => [ :new ]
  after_filter :clear_session_like_vars, :only => [:create]

  def create
    self.resource = warden.authenticate!(auth_options)
    set_flash_message(:notice, :signed_in) if is_navigational_format?
    sign_in(resource_name, resource)
    create_like_unless
    respond_with resource, :location => after_sign_in_path_for(resource)
  end

  def failure
    return render:json => {:errors => ["Login failed."], :status => :unprocessable_entity}
  end

  private
  def create_like_unless()
    if session[:pitch_id].present?
      pitch = Pitch.find_by_identifier(session[:pitch_id])
      pitch_liked = pitch.liked?(current_user)
    
      unless pitch_liked
        like = Like.new
        like.pitch = pitch
        like.user = current_user
        like.save
      end
    end
  end

  def clear_session_like_vars
    session[:pitch_id] = nil
    session[:show_redirect] = nil
  end
end
