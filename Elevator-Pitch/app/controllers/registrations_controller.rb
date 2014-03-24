class RegistrationsController < Devise::RegistrationsController
  layout false , :only => [ :new, :create ]

  def update
    @user = User.find(current_user.id)
    if params[:change_password]
      update_password
    else
      update_profile
    end
  end
  
  protected
    
  def after_inactive_sign_up_path_for(resource)
    registration_successful_path
  end

  private
  def update_password
    if @user.update_with_password(params[:user])
      set_flash_message :notice, :updated
      sign_in @user, :bypass => true
      redirect_to after_update_path_for(@user)
    else
      render :change_password
    end
  end

  def update_profile
    if @user.update_without_password(params[:user])
      set_flash_message :notice, :updated
      sign_in @user, :bypass => true
      pitch = current_user.pitch
      if pitch && pitch.just_created?
        redirect_to(pitch_path)
      else
        redirect_to after_update_path_for(@user)
      end
    else
      render "edit"
    end
  end
end