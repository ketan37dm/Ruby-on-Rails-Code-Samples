class AddressesController < ApplicationController
  before_filter :authenticate_user!
  
  # create home_address
  def create
    @user = User.find(params[:id])
    if @user
      @creator = current_user
      @address = @user.addresses.build(params[:address])
      @address.creator_id = @creator.id
      if @address.valid? && @address.save
        flash.now.notice = "Address added successfully"
      end
    else
      flash.now.notice = "User not found"
    end
  end

  # update home_address
  def update
    @user = User.find(params[:id])
    if @user
      @creator = current_user
      @address = ((params[:address][:category] == "home") ? @user.home_address : @user.school_address)
      @address.creator_id = @creator.id
      if @address.update_attributes(params[:address]) #&& @address.update_attribute(:creator_id, @creator_id)
        flash.now.notice = "Address updated successfully"
      end
    else
      flash.now.notice = "User not found"
    end
  end

  def remove_school_address
  end

end
