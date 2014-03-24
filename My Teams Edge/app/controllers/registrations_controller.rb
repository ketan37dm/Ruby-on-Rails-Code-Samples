class RegistrationsController < Devise::RegistrationsController

  def new
  end

  def create
  end

  def confirm_new_email
    user = User.find_by_identifier( params[:identifier] ) 
    return redirect_to root_path, :flash => { :notice => "User not found" } if user.blank?
    if user.update_attribute(:email, user.new_email) && user.update_attribute(:new_email, nil)
      redirect_to root_path, :flash => { :notice => "Your Email has been updated successfully." }
    end
  end

end
