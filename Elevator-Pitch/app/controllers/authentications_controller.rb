class AuthenticationsController < ApplicationController

  def create
    omniauth = request.env["omniauth.auth"]
    authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
    if authentication
      flash[:notice] = "Signed in successfully."
      sign_in_and_redirect(:user, authentication.user)
    else
      user = User.new
      user.apply_omniauth(omniauth)

      if omniauth['provider'] == "facebook"
        user.email = omniauth['info']['email'] 
      elsif omniauth['provider'] == "twitter"
        user.email_required?
      end

      user.name = omniauth['info']['name'].split(" ")[0].humanize
      
      user.password_required?
      
      if user.valid? && user.save
        flash[:notice] = "Signed in successfully."
        session[:omniauth] = nil unless user.new_record?
        sign_in_and_redirect(:user, user)
      else
        session[:omniauth] = omniauth.except('extra')
        redirect_to new_user_session_url
      end
    end
  end

  ####################################################################################################
  protected
  # This is necessary since Rails 3.0.4
  # See https://github.com/intridea/omniauth/issues/185
  # and http://www.arailsdemo.com/posts/44
  def handle_unverified_request
    true
  end
end
