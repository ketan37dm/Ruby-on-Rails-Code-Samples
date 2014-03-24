class Admins::AccountsController < ApplicationController
  before_filter :authenticate_admin!

  def add
    @package = params[:package]
    @payer = Payer.new
  end

  def create
    #find this in application controller
    create_new_sign_up
  end

  def remove
    user_sport = UserSport.find_by_id(params[:user_sport_id])

    if user_sport && user_sport.subvarsity_id.present? && user_sport.role == User::ROLES[:acc_owner]
      # Check subvarsity account and delete all users which belong to subvarsity
      # Except those users who have muliple user sports. For then delete user sport
      subvarsity_id = user_sport.subvarsity_id
      @subvarsity_users = User.get_users_for(user_sport.sport, user_sport.organization, :subvarsity_id => subvarsity_id)
      delete_users(@subvarsity_users, user_sport)
      subvarsity = UserHighschoolSubvarsity.find(subvarsity_id)
      subvarsity.update_attribute(:active, false)
      flash[:notice] = "Account successfully deleted."

    elsif user_sport && user_sport.role == User::ROLES[:acc_owner]
      @subvarsity_accounts = user_sport.subvarsity_accounts
      @users = User.get_users_for(user_sport.sport, user_sport.organization)
      delete_users(@users, user_sport)
      @subvarsity_accounts.each do |account|
        @users = User.get_users_for(account.sport, account.organization, :subvarsity_id => account.subvarsity_id)
        delete_users(@users, account)
      end
      flash[:notice] = "Account successfully deleted."
    else
      flash[:alert] = "Account not found to delete."
    end
    redirect_to admins_active_accounts_path
  end

  private

  def create_elite_edge
    @payer = Payer.new(params[:payer])
    @package = @payer.update_on = params[:package]

    if @payer.create_elite_edge
      flash[:notice] = "Account created successfully! An email has been sent with details."
      return redirect_to add_admins_accounts_path
    else
      render "add"
    end
  end

  def create_football_edge
    @payer = Payer.new(params[:payer])
    @package = @payer.update_on = params[:package]

    if @payer.create_football_edge
      flash[:notice] = "Account Created Successfully! An email has been sent with details."
      return redirect_to add_admins_accounts_path
    else
      render "add"
    end
  end

  def delete_users(users, user_sport)
    users.each do |user|
      if user.user_sports.count > 1
        user_sport = user.user_sports.where(:sport_id => user_sport.sport_id,
                                            :organization_id => user_sport.organization_id,
                                            :subvarsity_id => user_sport.subvarsity_id).first
        user_sport.delete
      else
        user.destroy
      end
    end
  end

end
