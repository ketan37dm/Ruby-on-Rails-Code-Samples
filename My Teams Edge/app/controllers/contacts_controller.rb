class ContactsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_user_organization
  before_filter :load_user
  before_filter :load_users_rolewise, :only => [:index]
  before_filter :symbolize_update_on_for_user, :only => [:update_personal_info]
#  before_filter :authenticate_creator!, :only => [ :edit, :update ]

	def show
    @user = User.find(params[:id]) rescue nil
    flash.now.notice = "User not found" if @user.blank?
  end 

  # CRUD for a new Personal Contact
  def new
    @user = User.find(params[:id]) rescue nil
    @creator = current_user
    @contact = @user.personal_contacts.build( :creator_id => @creator.id )
  end

  def create
    if !params[:personal_contact].blank?
      @contact = PersonalContact.new(params[:personal_contact])
      if @contact.valid? && @contact.save
        flash.now.notice = "Contact added successfully."
      end
    else
      flash.now.notice = "Contact could not be created."
    end
  end

  def edit
    @contact = PersonalContact.find(params[:id])
    if !@contact.blank?
      @user = @contact.user
      @creator = @contact.creator
    else
      flash.now.notice = "Contact not found."
    end
  end

  def update
    if !params[:id].blank?
      @contact = PersonalContact.find(params[:id])
      if @contact.update_attributes(params[:personal_contact])
        flash.now.notice = "Contact updated successfully."
      end
    else
      flash.now.notice = "Contact not found."
    end
  end

  # Landing page for every contact
  def contacts_info
    @user = User.find(params[:id])    
    @contacts = @user.personal_contacts
  end
  
  #######################################  More Info Tab  ##########################################
  def more_info
    @user = User.find(params[:id]) rescue nil
    @creator = current_user
    @home_address = (@user.home_address.present? ? @user.home_address : Address.new)
    @school_address = (@user.school_address.present? ? @user.school_address : Address.new)
  end

  def update_personal_info
    @user = User.find(params[:id]) rescue nil
    if @user
      flash.now.notice = "User updated successfully." if @user.update_attributes(params[:user])
    else
      flash.now.notice = "User not found."
    end
  end

  ######################################  private  #################################################

  private
  def load_users_rolewise
    @coaches    = User.get_users_rolewise(User::ROLES[:coach], current_sport, @organization, session[:subvarsity_id])
    @players    = User.get_users_rolewise(User::ROLES[:player], current_sport, @organization, session[:subvarsity_id])
    @aux_users  = User.get_users_rolewise(User::ROLES[:aux_user], current_sport, @organization, session[:subvarsity_id])
  end

  # Might be required in future
=begin
  def authenticate_creator!
    if !params[:id].blank?
      @contact = PersonalContact.find(params[:id])
      if current_user != @contact.creator
        return redirect_to contacts_path, :flash.notice = "You are not authorised for this action"
      end
    end
  end
=end

end
