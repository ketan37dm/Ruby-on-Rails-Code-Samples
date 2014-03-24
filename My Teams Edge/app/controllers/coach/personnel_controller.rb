class Coach::PersonnelController < ApplicationController

  before_filter :authenticate_user!
  before_filter :authenticate_account_owner!
  before_filter :load_user_organization

  def index
    @custome_sports_unit = CustomSportsUnit.new
    @show_players = (params[:player] == "1")
  end

  def list_roles_with_user_count
    @roles_with_user_count = User.roles_count_hash_for_sport(current_sport, @organization, session[:subvarsity_id])
    
    #delete he acc manager and admin roles
    ["acc_owner", "admin"].map { |role| @roles_with_user_count.delete(role) }
    #add the account manager as coach in the hash
    if @roles_with_user_count["coach"].present?
      @roles_with_user_count["coach"] = @roles_with_user_count["coach"].to_i + 1
    else
      @roles_with_user_count = @roles_with_user_count.reverse_merge("coach" => @roles_with_user_count["coach"].to_i + 1)
    end
    #add players and roles if they are empty in the hash
    [User::ROLES[:player], User::ROLES[:aux_user]].each{|role| @roles_with_user_count = @roles_with_user_count.merge({role => "0"}) if @roles_with_user_count[role].blank? }
  end

  def list_users_rolewise
    @role = params[:role]
    @users = User.get_users_rolewise(@role, current_sport, @organization, session[:subvarsity_id])    
  end

  def remove_user_sport
    # destroy the UserSport record if corresponding user is associated with more than one sports.
    # destroy the UserSport and User record as well if the corresponding user is associated with only one sport.
    @user = User.find(params[:id])
    role = @user.role_in_sport(current_sport, session[:subvarsity_id])
    user_sport = UserSport.where( 
        :sport_id => current_sport.id,
        :user_id => @user.id,
        :subvarsity_id => session[:subvarsity_id]
      ).first

    if user_sport.destroy
      #destroy the user followings if it is player
      Follow.where(:following_id => @user.id, :sport_id => current_sport.id).delete_all
      flash.now[:notice] = "User removed from the group."
    else
      flash.now[:notice] = "User not found !"
    end

    #change user's password so he wouldn't be able to login if the corresponding user is associated with only one sport.
    @user.destroy if @user.user_sports.count == 0
    @user_count = User.get_user_count_for_role(role, current_sport, @organization, session[:subvarsity_id])
  end

  def resend_invitation
    # resend_invitation to users who have been added by the coach but have not been registered yet with MTE
    unless params[:id].blank?
      user = User.find(params[:id])
      sports_count = user.user_sports.count
      if sports_count == 1
        NotificationMailer.registration_successful(user).deliver 
      elsif sports_count > 1
        user_sport = user.user_sports.where(:sport_id => current_sport.id, :subvarsity_id => session[:subvarsity_id]).first
        NotificationMailer.send_sport_added_notification(user, user_sport).deliver
      end
      flash.now[:notice] = "Resent invitation successfully"
    else
      flash.now[:notice] = "User not found !"
    end
  end

  def user_account_details
    @user = User.find(params[:id]) unless params[:id].blank?
  end
  
  def list_units_with_user_count
    @custom_sports_units = CustomSportsUnit.units_for_sport(current_sport, @organization, session[:subvarsity_id])

    @units_with_user_count = @custom_sports_units.map{ |unit|
      [unit.unit_name, unit.user_sports_units.count]
    }
  end

  def list_users_unitwise
    @unit = params[:unit]
    
    custom_sports_unit_id = CustomSportsUnit.where(
          :sport_id         => current_sport.id, 
          :unit_name        => @unit, 
          :organization_id  => @organization.id,
          :subvarsity_id    => session[:subvarsity_id]
        ).pluck(:id).first

    @users = User.includes(:user_sports_units).
              where("user_sports_units.custom_sports_unit_id = #{custom_sports_unit_id}")
  end

  def create_sport_unit
    @custom_sports_unit = CustomSportsUnit.new(
          params[:custom_sports_unit].merge({:subvarsity_id => session[:subvarsity_id]})
        )
      if @custom_sports_unit.save
        @user_images = []
        @user_emails = []
        users =  User.get_users_for(current_sport, @organization, :subvarsity_id => session[:subvarsity_id], :registered => true)

        users.each{ |user|
          @user_emails << "#{user.full_name}(#{user.email})"
          @user_images << user.image.url(:thumb)
        }

        #these two variables are defiend to display thhe unit on page incase user is viewing the unit
        @units_with_user_count = [@custom_sports_unit.unit_name, 0]
        @count = 0
      end
  end

  def add_users_to_sport_unit
    @custom_sports_unit = CustomSportsUnit.find_by_id(params["unit-id"])

    #seperate the email address from the string
    emails = params["users-for-unit"].scan(/\(.*?\)/).map{|email| email[1..-2]}

    users = User.where("email in ('#{emails.join("','")}')")

    users.each{|user| user.user_sports_units.create!(custom_sports_unit_id: @custom_sports_unit.id) }

    #this is defined to update the number of users added after creating the unit
    @count = users.size
  end

  def remove_unit
    @unit = CustomSportsUnit.where(
        :unit_name => params[:unit_name],
        :organization_id => @organization.id,
        :sport_id => current_sport.id,
        :subvarsity_id => session[:subvarsity_id]
      ).first

    @unit.destroy
    @unit_count = current_user.custom_sports_units.where(:subvarsity_id => session[:subvarsity_id]).count 
  end

  def reomve_user_unit
    @user = User.find_by_id(params[:user_id])
    UserSportsUnit.includes(:custom_sports_unit).
      where(
            :"custom_sports_units.sport_id"         => current_sport.id, 
            :"custom_sports_units.organization_id"  => @organization.id,
            :"custom_sports_units.unit_name"        => params[:unit_name],
            :"custom_sports_units.subvarsity_id"    => session[:subvarsity_id],
            :"user_sports_units.user_id"            => @user.id
           ).first.delete

    @user_count = UserSportsUnit.includes(:custom_sports_unit).
                  where(
                      :"custom_sports_units.sport_id"         => current_sport.id, 
                      :"custom_sports_units.organization_id"  => @organization.id,
                      :"custom_sports_units.unit_name"        => params[:unit_name],
                      :"custom_sports_units.subvarsity_id"    => session[:subvarsity_id]
                    ).count
  end

  def post_message
    @unit = params[:unit]
    @new_update = UserUpdate.new
    @new_event = UserEvent.new
    @custom_sports_unit = CustomSportsUnit.where(
                              :sport_id         => current_sport.id,
                              :organization_id  => @organization.id,
                              :unit_name        => @unit,
                              :subvarsity_id    => session[:subvarsity_id]
                            ).first
  end
  
  def add_user
    @role = params[:role] 
    @new_user = User.new
    set_entity_name(@role)
  end

  def create_user
    params[:user][:update_on] = params[:user][:update_on].to_sym if params[:user].present? && params[:user][:update_on].present?
    @role = params[:user][:role]
    set_entity_name(@role)
    @new_user = User.save_with_sport(params[:user])
    NotificationMailer.send_sport_added_notification(@new_user, @new_user.user_sports.last).deliver if @new_user.errors.blank? && @new_user.user_sports.count > 1
    @user_count = User.get_user_count_for_role(@role, current_sport, @organization, session[:subvarsity_id])
  end

  protected

    def set_entity_name(role)
      case @role
      when "coach" 
        @entity_name = "Coach"
      when "player"
        @entity_name = "Player"
      when "aux_user"
        @entity_name = "Auxiliary User"
      end
    end
  
end
