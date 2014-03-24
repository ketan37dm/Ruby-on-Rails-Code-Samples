class Admins::HomeController < ApplicationController

  before_filter :authenticate_admin!


  def index
  end

  def edit_password
  	@admin = current_admin
  end

  def update_password
  	@admin = current_admin
    if @admin.update_with_password(params[:admin])
      sign_in(@admin, :bypass => true)
      flash[:notice] = 'Password updated successfully'
      redirect_to admins_root_path
    else
      render :action => :edit_password
    end
  end

end
