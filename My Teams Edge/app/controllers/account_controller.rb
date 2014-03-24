class AccountController < ApplicationController
  before_filter :authenticate_user!, :except => [:confirm_sport]
  before_filter :load_user_organization, :except => [:confirm_sport]

  before_filter :ensure_high_school_manager, :only => [:new_sport, :create_sport, :sub_varsity]
  before_filter :authenticate_account_owner!, :only => [:new_sport, :create_sport, :sub_varsity]
  before_filter :symbolize_update_on_for_user, :only => [:new_sport, :create_sport, :sub_varsity]
  before_filter :get_registerd_sports_ids, :only => [:new_sport]

  before_filter :load_user

  def basics
  end

  def update_basics
    if @user.update_attributes(params[:user])
      flash[:notice] = 'Successfully updated'
      redirect_to account_basics_path
    else
      render action: :basics
    end
  end

  def change_password
  end

  def update_password
    @change_password = true
    if @user.update_with_password(params[:user])
      sign_in(@user, :bypass => true)
      flash[:notice] = 'Password updated successfully'
      redirect_to account_change_email_path
    else
      render :action => :change_email
    end
  end

  def change_email

  end

  def update_email
    @user.create_unique_token
    @change_email = true
    if @user.update_with_password(params[:user])
      #TODO Send an email to user
      sign_in(@user, :bypass => true)
      flash[:notice] = "Your new email needs to be confirmed. We have sent you an email with confirmation instructions." 
      redirect_to account_change_email_path
    else
      render :action => :change_email
    end
  end

  def new_sport
    @new_account_manager = User.new
  end

  def create_sport
    @new_account_manager = User.save_with_sport(params[:user])
    get_registerd_sports_ids
    if @new_account_manager.errors.present?
      return render "new_sport"
    else
      flash[:notice] = "Account added successfully"
      NotificationMailer.send_sport_added_notification(@new_account_manager, @new_account_manager.user_sports.last).deliver
      return redirect_to new_sport_account_path
    end
  end

  def sub_varsity
    @sub_varsities = UserHighschoolSubvarsity.sub_varsities_for(current_sport, @organization)
    if request.post?
      get_sub_varsity

      @subvarsity_manager = nil
      params[:subvarsity_id] = params[:subvarsity_id].to_i
      if params[:user]
        @subvarsity_manager = User.save_with_sport(params[:user])
      else
        @subvarsity_manager = User.get_subvarsity_manager(
            params[:subvarsity_id],
            current_sport.id,
            @organization.id
          ) if @subvarsity_manager.blank?

        @subvarsity_manager = User.new if @subvarsity_manager.blank? || @sub_varsity.set_account_deletion?
      end

      if @subvarsity_manager.persisted?
        @sub_varsity.update_attribute(:active, true) if !@sub_varsity.active? && !@sub_varsity.set_account_deletion?
        @users_count = User.subvarsity_users_count(params[:subvarsity_id], current_sport.id, @organization.id)
      end
      
      @partial_name = @sub_varsity.active? ? "show_sub_varsity" : "register_sub_varsity"

      @subvarsity_name = UserHighschoolSubvarsity.where(
              :id => params[:subvarsity_id]
            ).pluck(:name).first
    end

  end

  def remove_sub_varsity
    #this is a database heavy so moving it into background
    UserSport.delay.
      delete_all_subvarsity_sports_and_users(
          params[:subvarsity_id].to_i, 
          current_sport.id,
          @organization.id
        )

    get_sub_varsity
    @sub_varsity.update_attributes(:active => false, :set_account_deletion => true)

    flash[:notice] = "Account set for deletion"
    return redirect_to sub_varsity_account_path
  end

  def confirm_sport
    user_sport = UserSport.where(:confirmation_identifier => params[:identifier]).first
    return redirect_to root_url if user_sport.blank?

    user_sport.skip_check_user_sport = true
    if user_sport.update_attributes(:confirmation_identifier => nil, :confirmed_at => Time.now)
      return redirect_to new_user_session_path, :notice => "Account confirmed. Please login"
    else
      return redirect_to root_url, :notice => "Problem confirming account. Please contact account manager"
    end
  end

  protected

    def get_registerd_sports_ids
      @organization_registered_sports_ids = User.get_organization_sports_ids(@organization)
    end

    def ensure_high_school_manager
      if !@organization.is_a?(HighSchool)
        return redirect_to default_url(current_user)
      end
    end

    def get_sub_varsity
      @sub_varsity = UserHighschoolSubvarsity.find(params[:subvarsity_id])
    end

end
