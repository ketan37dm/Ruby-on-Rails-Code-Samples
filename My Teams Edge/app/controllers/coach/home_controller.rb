class Coach::HomeController < ApplicationController

  before_filter :authenticate_user!
  before_filter :authenticate_account_owner!
  before_filter :load_user
  before_filter :load_user_organization, :only => [:search_users_and_units, :post_update, :post_event]
  before_filter :validate_xhr_request, only: [:add_new_user, :add_opponent, :remove_opponent, :remove_user]
  before_filter :symbolize_update_on_for_user, only: [:upload_photo, :add_new_user, :add_opponent]
  before_filter :home_page_events, only: [:index]

  include ControllerHelpers::CommonMethods

  def index
    @show_welcome_screen = show_welcome_screen?
    if @show_welcome_screen
      @new_user = User.new
      @new_opponent = Opponent.new
    end
    @opponents = current_user.upcoming_opponents(current_sport.id, session[:subvarsity_id])
    @new_update = UserUpdate.new
    @new_event = UserEvent.new
  end

  def search
   if params[:term].present?
     users = current_user.organization_sport_team(current_sport).search(params[:term])
     opponents = current_user.organization_team_opponents(current_sport, session[:subvarsity_id]).search(params[:term])
     @users_opponents = users + opponents
   else
     @users_opponents = []
   end

   render json: @users_opponents.compact.map { |u| Hash[ id: "#{u.class}-#{u.id}",
                                                  label:(u.full_name rescue u.name),
                                                  name: (u.full_name rescue u.name)] }
  end

  def get_record
    if params["typeid"].present?
      record_type, record_id = params[:typeid].split("-")
      obj = eval(record_type).find(record_id.to_i)
      redirect_to schedule_opponents_path(opponent_id: record_id.to_i) and return if obj.class == Opponent
    end
    redirect_to_current_user_default_url
  end

  def add_new_user
    @new_user = User.save_with_sport(params[:user])
    NotificationMailer.send_sport_added_notification(@new_user, @new_user.user_sports.last).deliver if @new_user.errors.blank? && @new_user.user_sports.count > 1
  end

  def add_opponent
    @new_opponent = Opponent.new(params[:opponent])
    @new_opponent.save
  end

  def remove_opponent
    if params[:opponent_id]
      opponent = Opponent.where(:id => params[:opponent_id], :subvarsity_id => session[:subvarsity_id]).first
      @opponent_id = opponent.id
      opponent.destroy
    end
  end

  def remove_user
    if params[:user_id]
      user = User.find_by_id(params[:user_id])
      @user_id = user.id
      user.destroy
    end
  end

  def change_sport_session
    sport_id = params[:sport_id]
    session[:subvarsity_id] = params[:subvarsity_id].present? ? params[:subvarsity_id].to_i : nil
    set_current_sport(sport_id.try(:to_i)) if sport_id.present?
    
    flash[:notice] = 'Sport changed successfully'
    respond_to do |format|
      format.html { redirect_to coach_home_index_path}
      format.js { render :js => "window.location = '#{coach_home_index_path}'" }
    end
  end

  def post_update
    csu_ids = params[:user_update][:custom_sports_unit_ids].split(",")
    params[:user_update].merge!(:custom_sports_unit_ids => csu_ids,
                              :organization_id => @organization.id,
                              :subvarsity_id => session[:subvarsity_id] )
    @new_update = UserUpdate.new(params[:user_update])
    @new_update.save
  end

  def search_users_and_units
    @custom_sports_units = CustomSportsUnit.units_for_sport(current_sport, @organization)
    @users = User.team_users_for(current_sport, @organization)
  end

  def post_event
    csu_ids = params[:user_event][:custom_sports_unit_ids].split(",")
    params[:user_event].merge!(:custom_sports_unit_ids => csu_ids,
                              :organization_id => @organization.id,
                              :subvarsity_id => session[:subvarsity_id] )
    @new_event = UserEvent.new(params[:user_event])
    @new_event.save
    @upcoming_day = @new_event.due_day if @new_event.errors.blank?
  end

  def create_psudeo_name
    @new_psudeo_name = current_user.organization_psudeo_names.create(
                          name: params[:name],
                          organization_id: current_user.organization.id,
                          sport_id: current_sport.id,
                          subvarsity_id: session[:subvarsity_id]
                        )
  end

  def update_psudeo_name
    @current_psudeo_name = current_user.active_name_for_organization(current_sport.id, session[:subvarsity_id])
    @new_psudeo_name = current_user.organization_psudeo_names.where(["name = ? and sport_id = ? and (active is null or active = false)", params[:name], current_sport.id]).where(:subvarsity_id => session[:subvarsity_id]).first
    if @current_psudeo_name != @new_psudeo_name
      @current_psudeo_name.update_attributes(active: false) if !@current_psudeo_name.blank? && !@current_psudeo_name.is_a?(Organization)
      @new_psudeo_name.update_attributes(active: true) unless @new_psudeo_name.blank?
    end
  end

end
