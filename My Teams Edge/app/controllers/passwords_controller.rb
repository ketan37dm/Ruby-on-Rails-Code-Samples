class PasswordsController < Devise::PasswordsController

  def new 
    # if params[:reset_password_token] is present use devise view.
    # if params[:idetifier] is present use register_account partial
    if params[:identifier].present?
      @user = User.find_by_identifier(params[:identifier])
      @register_account = true
      if @user.nil?
        flash[:alert] = "Confirmation link is no more valid or User may not exist"
        redirect_to new_user_session_path
      end
    else
      super
    end
  end

  def create
    if params[:identifier].present?
      @user = User.find_by_identifier(params[:identifier]) unless params[:identifier].blank?
      ( return redirect_to root_url, :flash => { :notice => "User not found !"} ) if @user.blank?
      if @user.update_attributes(params[:user])
        sign_in(:user, @user)
        session[:subvarsity_id] = @user.user_sports.last.subvarsity_id
        redirect_to_current_user_default_url
      else
        @register_account = true
        render :new
      end
    else
      super
    end
  end

end
